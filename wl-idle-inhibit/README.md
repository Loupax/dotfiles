# wl-idle-inhibit

Holds a `zwp_idle_inhibit_manager_v1` Wayland idle inhibitor until killed.
While running, the compositor does not accumulate idle time — swayidle
timeouts won't fire and the screen won't lock or turn off.

Intended to be managed by a shell wrapper that starts and kills it based on
media player state (see `startdwl`).

## How it works

On startup, the program:

1. Connects to the Wayland compositor socket
2. Binds `wl_compositor` and `zwp_idle_inhibit_manager_v1`
3. Creates a `wl_surface` and attaches an idle inhibitor to it
4. Blocks until `SIGTERM` or `SIGINT`

On exit the inhibitor and surface are destroyed, immediately restoring normal
idle behaviour.

No external dependencies — the Wayland wire protocol is implemented directly
using the standard library.

## Build & install

```sh
make wl-idle-inhibit-install
```

Or manually:

```sh
cd wl-idle-inhibit
go build -o wl-idle-inhibit .
sudo install -m755 wl-idle-inhibit /usr/local/bin/
```

## Usage

```sh
# Hold idle inhibitor until Ctrl-C
wl-idle-inhibit

# Typical wrapper: inhibit while playerctl reports Playing
while true; do
    while IFS= read -r status; do
        if [ "$status" = "Playing" ]; then
            wl-idle-inhibit & pid=$!
        else
            kill "$pid" 2>/dev/null; pid=""
        fi
    done < <(playerctl -F status 2>/dev/null)
    sleep 5
done
```

The `startdwl` script runs this wrapper automatically on session start.

## Testing

Run a short-timeout swayidle in one terminal and observe whether it fires:

```sh
# Without inhibitor — should print after 3 s of no input
swayidle timeout 3 'echo IDLE FIRED'

# With inhibitor — should stay silent indefinitely
wl-idle-inhibit &
swayidle timeout 3 'echo IDLE FIRED'
```
