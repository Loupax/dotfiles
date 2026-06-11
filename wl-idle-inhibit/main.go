// wl-idle-inhibit holds a Wayland idle inhibitor (zwp_idle_inhibit_manager_v1)
// until killed. Start it when media begins playing; kill it when it stops.
package main

import (
	"encoding/binary"
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"
)

// Fixed Wayland object IDs allocated by this client.
const (
	idDisplay   uint32 = 1 // always wl_display
	idRegistry  uint32 = 2
	idSync      uint32 = 3 // wl_callback used for roundtrip
	idCompositor uint32 = 4
	idManager   uint32 = 5 // zwp_idle_inhibit_manager_v1
	idSurface   uint32 = 6
	idInhibitor uint32 = 7
)

func main() {
	conn, err := dialWayland()
	if err != nil {
		log.Fatalf("connect: %v", err)
	}
	defer conn.Close()

	// wl_display.get_registry (opcode 1)
	send(conn, idDisplay, 1, u32(idRegistry))
	// wl_display.sync (opcode 0) — callback fires after all current globals are sent
	send(conn, idDisplay, 0, u32(idSync))

	var compositorName, compositorVersion uint32
	var managerName, managerVersion uint32

	// Read events until the sync callback fires.
	if err := dispatch(conn, func(obj, opcode uint32, data []byte) (done bool, err error) {
		switch {
		case obj == idDisplay && opcode == 0: // wl_display.error
			return true, parseDisplayError(data)

		case obj == idRegistry && opcode == 0: // wl_registry.global
			name, iface, version := parseGlobal(data)
			switch iface {
			case "wl_compositor":
				compositorName, compositorVersion = name, version
			case "zwp_idle_inhibit_manager_v1":
				managerName, managerVersion = name, version
			}

		case obj == idSync && opcode == 0: // wl_callback.done
			return true, nil
		}
		return false, nil
	}); err != nil {
		log.Fatalf("discover globals: %v", err)
	}

	if compositorVersion == 0 {
		log.Fatal("wl_compositor not available")
	}
	if managerVersion == 0 {
		log.Fatal("zwp_idle_inhibit_manager_v1 not available")
	}

	// wl_registry.bind (opcode 0)
	send(conn, idRegistry, 0, bind(compositorName, "wl_compositor", compositorVersion, idCompositor))
	send(conn, idRegistry, 0, bind(managerName, "zwp_idle_inhibit_manager_v1", managerVersion, idManager))

	// wl_compositor.create_surface (opcode 0)
	send(conn, idCompositor, 0, u32(idSurface))

	// zwp_idle_inhibit_manager_v1.create_inhibitor (opcode 1)
	send(conn, idManager, 1, append(u32(idInhibitor), u32(idSurface)...))

	// One more roundtrip to confirm everything landed without errors.
	const idSync2 = idInhibitor + 1
	send(conn, idDisplay, 0, u32(idSync2))
	if err := dispatch(conn, func(obj, opcode uint32, data []byte) (done bool, err error) {
		if obj == idDisplay && opcode == 0 {
			return true, parseDisplayError(data)
		}
		if obj == idSync2 && opcode == 0 {
			return true, nil
		}
		return false, nil
	}); err != nil {
		log.Fatalf("confirm inhibitor: %v", err)
	}

	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGTERM, syscall.SIGINT)
	<-sig

	// Graceful cleanup: destroy inhibitor and surface.
	// zwp_idle_inhibitor_v1.destroy (opcode 0)
	send(conn, idInhibitor, 0, nil)
	// wl_surface.destroy (opcode 0)
	send(conn, idSurface, 0, nil)
}

// dispatch reads Wayland events from conn, calling handler for each.
// Returns when handler signals done=true or returns a non-nil error.
func dispatch(conn *net.UnixConn, handler func(obj, opcode uint32, data []byte) (done bool, err error)) error {
	for {
		obj, opcode, data, err := readMsg(conn)
		if err != nil {
			return err
		}
		done, err := handler(obj, opcode, data)
		if err != nil {
			return err
		}
		if done {
			return nil
		}
	}
}

// --- Wire encoding helpers ---

func u32(v uint32) []byte {
	b := make([]byte, 4)
	binary.LittleEndian.PutUint32(b, v)
	return b
}

// wlString encodes a Wayland string: [length including null (4)] [data + null + padding].
func wlString(s string) []byte {
	slen := len(s) + 1                // include null terminator
	padded := (slen + 3) &^ 3        // round up to 4-byte boundary
	buf := make([]byte, 4+padded)     // length field + data (zero-initialised = null/padding)
	binary.LittleEndian.PutUint32(buf[:4], uint32(slen))
	copy(buf[4:], s)
	return buf
}

// bind builds the payload for wl_registry.bind.
// new_id without an explicit interface is encoded as: [name][iface string][version][id].
func bind(name uint32, iface string, version, newID uint32) []byte {
	var p []byte
	p = append(p, u32(name)...)
	p = append(p, wlString(iface)...)
	p = append(p, u32(version)...)
	p = append(p, u32(newID)...)
	return p
}

// send writes a Wayland request to conn.
func send(conn *net.UnixConn, objectID uint32, opcode uint16, payload []byte) {
	size := uint32(8 + len(payload))
	buf := make([]byte, size)
	binary.LittleEndian.PutUint32(buf[0:4], objectID)
	binary.LittleEndian.PutUint32(buf[4:8], size<<16|uint32(opcode))
	copy(buf[8:], payload)
	if _, err := conn.Write(buf); err != nil {
		log.Fatalf("send (object=%d opcode=%d): %v", objectID, opcode, err)
	}
}

// readMsg reads one Wayland event from conn.
func readMsg(conn *net.UnixConn) (objectID, opcode uint32, data []byte, err error) {
	header := make([]byte, 8)
	if _, err = io.ReadFull(conn, header); err != nil {
		return 0, 0, nil, fmt.Errorf("read header: %w", err)
	}
	objectID = binary.LittleEndian.Uint32(header[0:4])
	sizeOpcode := binary.LittleEndian.Uint32(header[4:8])
	opcode = uint32(sizeOpcode & 0xffff)
	size := int(sizeOpcode >> 16)
	if size > 8 {
		data = make([]byte, size-8)
		if _, err = io.ReadFull(conn, data); err != nil {
			return 0, 0, nil, fmt.Errorf("read payload: %w", err)
		}
	}
	return
}

// --- Event parsers ---

// parseGlobal parses a wl_registry.global event payload.
func parseGlobal(data []byte) (name uint32, iface string, version uint32) {
	name = binary.LittleEndian.Uint32(data[0:4])
	slen := binary.LittleEndian.Uint32(data[4:8])
	padded := int((slen + 3) &^ 3)
	iface = string(data[8 : 8+slen-1]) // strip null terminator
	version = binary.LittleEndian.Uint32(data[8+padded : 8+padded+4])
	return
}

// parseDisplayError parses a wl_display.error event payload and returns an error.
func parseDisplayError(data []byte) error {
	code := binary.LittleEndian.Uint32(data[4:8])
	slen := binary.LittleEndian.Uint32(data[8:12])
	msg := string(data[12 : 12+slen-1])
	return fmt.Errorf("compositor error code=%d: %s", code, msg)
}

// dialWayland connects to the Wayland compositor socket.
func dialWayland() (*net.UnixConn, error) {
	dir := os.Getenv("XDG_RUNTIME_DIR")
	if dir == "" {
		return nil, fmt.Errorf("XDG_RUNTIME_DIR not set")
	}
	display := os.Getenv("WAYLAND_DISPLAY")
	if display == "" {
		display = "wayland-0"
	}
	return net.DialUnix("unix", nil, &net.UnixAddr{Name: dir + "/" + display, Net: "unix"})
}
