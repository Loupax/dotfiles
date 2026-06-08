package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/rajveermalviya/go-wayland/wayland/client"
	idle_inhibit "github.com/rajveermalviya/go-wayland/wayland/unstable/idle-inhibit-v1"
)

func main() {
	display, err := client.Connect("")
	if err != nil {
		log.Fatalf("connect to wayland: %v", err)
	}
	defer display.Destroy()

	registry, err := display.GetRegistry()
	if err != nil {
		log.Fatalf("get registry: %v", err)
	}

	var compositor *client.Compositor
	var manager *idle_inhibit.IdleInhibitManager

	registry.SetGlobalHandler(func(e client.RegistryGlobalEvent) {
		switch e.Interface {
		case "wl_compositor":
			compositor = client.NewCompositor(display.Context())
			if err := registry.Bind(e.Name, e.Interface, e.Version, compositor); err != nil {
				log.Fatalf("bind wl_compositor: %v", err)
			}
		case "zwp_idle_inhibit_manager_v1":
			manager = idle_inhibit.NewIdleInhibitManager(display.Context())
			if err := registry.Bind(e.Name, e.Interface, e.Version, manager); err != nil {
				log.Fatalf("bind zwp_idle_inhibit_manager_v1: %v", err)
			}
		}
	})

	if err := roundtrip(display); err != nil {
		log.Fatalf("roundtrip: %v", err)
	}

	if compositor == nil {
		log.Fatal("wl_compositor not available")
	}
	if manager == nil {
		log.Fatal("zwp_idle_inhibit_manager_v1 not available")
	}

	surface, err := compositor.CreateSurface()
	if err != nil {
		log.Fatalf("create surface: %v", err)
	}

	inhibitor, err := manager.CreateInhibitor(surface)
	if err != nil {
		log.Fatalf("create inhibitor: %v", err)
	}

	if err := roundtrip(display); err != nil {
		log.Fatalf("roundtrip: %v", err)
	}

	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGTERM, syscall.SIGINT)
	<-sig

	inhibitor.Destroy()
	surface.Destroy()
}

// roundtrip sends a sync request and dispatches events until the callback fires,
// ensuring all previously sent requests have been processed by the compositor.
func roundtrip(display *client.Display) error {
	done := false
	cb, err := display.Sync()
	if err != nil {
		return err
	}
	cb.SetDoneHandler(func(client.CallbackDoneEvent) {
		done = true
	})
	for !done {
		if err := display.Context().Dispatch(); err != nil {
			return err
		}
	}
	return cb.Destroy()
}
