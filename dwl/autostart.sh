#!/bin/sh
# Sourced by dwl via -s. DOTFILES must be set by the caller.

start_bars() {
    local my_user
    my_user=$(id -un)

    pkill -u "$my_user" -x someblocks 2>/dev/null
    pkill -u "$my_user" -x somebar 2>/dev/null

    while pgrep -u "$my_user" -x "someblocks|somebar" >/dev/null 2>&1; do
        sleep 1
    done

    swaybg -i "$DOTFILES/wallpaper.jpg" -m fill -c 1B2E4D &

    [ -n "$XDG_RUNTIME_DIR" ] && rm -f "$XDG_RUNTIME_DIR"/somebar-*

    swaync &
    somebar &
    someblocks &

    pactl subscribe 2>/dev/null | grep --line-buffered "sink" | \
        while read -r _; do pkill -RTMIN+2 someblocks 2>/dev/null; done &

    playerctl -F status 2>/dev/null | \
        while read -r _; do pkill -RTMIN+3 someblocks 2>/dev/null; done &

    swaync-client --subscribe 2>/dev/null | \
        while read -r _; do pkill -RTMIN+4 someblocks 2>/dev/null; done &
}

idle_inhibit_when_playing() {
    local inhibit_pid=""
    playerctl -F status 2>/dev/null | while IFS= read -r status; do
        if [ "$status" = "Playing" ]; then
            [ -z "$inhibit_pid" ] && { wl-idle-inhibit & inhibit_pid=$!; }
        else
            [ -n "$inhibit_pid" ] && { kill "$inhibit_pid" 2>/dev/null; wait "$inhibit_pid" 2>/dev/null; inhibit_pid=""; }
        fi
    done
}

autostart() {
    pgid_file="${XDG_RUNTIME_DIR:-/tmp}/dwl-bars.pgid"
    if [ -f "$pgid_file" ]; then
        old_pgid=$(cat "$pgid_file")
        case "$old_pgid" in
            *[!0-9]*|"") ;;
            *) [ "$old_pgid" -gt 1 ] && kill -- -"$old_pgid" 2>/dev/null ;;
        esac
    fi
    ps -o pgid= -p $$ | tr -d ' ' > "$pgid_file"

    rm -f /tmp/.X11-unix/X1 /tmp/.X1-lock
    xauth add :1 . $(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')
    Xwayland :1 -auth ~/.Xauthority -nolisten tcp -rootless &
    dbus-update-activation-environment --systemd DISPLAY=:1 XAUTHORITY=~/.Xauthority \
        XDG_CURRENT_DESKTOP=sway WAYLAND_DISPLAY="$WAYLAND_DISPLAY"

    until [ -S "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY:-wayland-0}" ]; do
        sleep 0.05
    done

    swayidle -w timeout 180 'lock-session' before-sleep 'lock-session' &
    swayidle timeout 300 'wlopm --off \*' resume 'wlopm --on \*' &

    playerctld &
    idle_inhibit_when_playing &
    start_bars
}

autostart
