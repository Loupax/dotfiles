# dotfiles

Personal configuration files, symlinked into place. The neovim config is a git submodule (it has its own repo with plugin submodules); dwl, somebar, someblocks, and wlroots are git subtrees; everything else is tracked directly.

## Structure

| Path | Symlink target |
|---|---|
| `waybar-work/` | `~/.config/waybar` |
| `sway-work/` | `~/.config/sway` |
| `tmux/` | `~/.config/tmux` |
| `tofi/` | `~/.config/tofi` |
| `foot/` | `~/.config/foot` |
| `bashrc` | `~/.bashrc` |
| `sessionizer/tmux-sessionizer` | `~/.local/bin/tmux-sessionizer` |
| `scripts/recorder` | `~/.local/bin/recorder` |

### Submodule

| Path | Repository | Symlink target |
|---|---|---|
| `nvim/` | [Loupax/nvim.lua](https://github.com/Loupax/nvim.lua) | `~/.config/nvim` |

### Subtrees

| Path | Repository | Notes |
|---|---|---|
| `dwl/` | [Loupax/dwl](https://github.com/Loupax/dwl) | Wayland compositor — build and install from here |
| `st/` | [Loupax/st](https://github.com/Loupax/st) | Simple terminal (patched with alpha transparency) |
| `somebar/` | [Loupax/somebar](https://github.com/Loupax/somebar) | Status bar for dwl |
| `someblocks/` | [Loupax/someblocks](https://github.com/Loupax/someblocks) | Status block runner for somebar |
| `wlroots/` | [Loupax/wlroots](https://github.com/Loupax/wlroots) | Vendored wlroots 0.19 — built locally, not installed system-wide |
| `dmenu/` | [suckless/dmenu](https://tools.suckless.org/dmenu/) | Dynamic menu — patched for centered floating mode, runs via Xwayland |
| `waylock/` | [Loupax/waylock](https://github.com/Loupax/waylock) | Wayland screen locker (v1.5.0, Zig 0.15 compatible) |

Subtrees are regular directories — no special clone steps needed. Set up the required git remotes first:

```bash
make remotes
```

Then sync upstream changes:

```bash
make update
```

To push local changes back to the individual repos:

```bash
make push
```

## Initial setup

```bash
git clone --recurse-submodules https://github.com/Loupax/dotfiles.git
cd dotfiles
```

If you already cloned without `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

## Dependencies

Before building, install the required packages.

**Arch Linux:**

```bash
sudo pacman -S xorg-xwayland xcb-util-wm swaync meson ninja libxinerama libxft \
  pipewire-pulse wireplumber noto-fonts-emoji nodejs swayidle wlopm
```

**Ubuntu 24.04:**

```bash
sudo apt-get install -y libinput-dev libxcb-icccm4-dev libpixman-1-dev libdrm-dev \
  libxkbcommon-dev wayland-protocols libseat-dev hwdata libdisplay-info-dev \
  libliftoff-dev libxcb-composite0-dev libxcb-render0-dev libxcb-xinput-dev \
  libxcb-ewmh-dev libxcb-res0-dev xwayland swaync meson ninja-build libpam0g-dev \
  xdg-desktop-portal xdg-desktop-portal-wlr
```

**Fedora:**

```bash
sudo dnf copr enable erikreider/SwayNotificationCenter -y && \
sudo dnf install -y \
  gcc gcc-c++ meson ninja-build pkgconf-pkg-config \
  wayland-devel wayland-protocols-devel libinput-devel libdrm-devel \
  mesa-libEGL-devel mesa-libGL-devel pixman-devel libxkbcommon-devel \
  libseat-devel hwdata libdisplay-info-devel libliftoff-devel \
  libxcb-devel xcb-util-wm-devel xcb-util-renderutil-devel systemd-devel \
  xorg-x11-server-Xwayland xorg-x11-server-Xwayland-devel \
  cairo-devel pango-devel \
  webkit2gtk4.1-devel gtk3-devel \
  libX11-devel libXft-devel libXinerama-devel \
  pam-devel \
  swayidle wireplumber pipewire-pulseaudio wlopm swaync \
  xdg-desktop-portal xdg-desktop-portal-wlr \
  google-noto-color-emoji-fonts
```

| Package | Purpose |
|---|---|
| `xorg-xwayland` | X11 compatibility layer — required to run X11 apps (Steam, etc.) |
| `xcb-util-wm` / `libxcb-icccm4-dev` | Required to build dwl with Xwayland support |
| `swaync` | Notification daemon |
| `meson`, `ninja` | Build system for wlroots and somebar |
| `pipewire-pulse` | PulseAudio compatibility layer — required for `pactl subscribe` in `startdwl`, which signals someblocks to update the volume block on keypress |
| `noto-fonts-emoji` | Emoji fallback font — required to render flag emojis in the language block |
| `nodejs` | Required for the caveman Claude Code plugin's session hooks |
| `swayidle` | Idle daemon — triggers screen-off and lock after inactivity |
| `wlopm` | Wayland output power management — turns displays off/on |
| `xdg-desktop-portal` | Portal service — required for screen sharing via PipeWire |
| `xdg-desktop-portal-wlr` | wlroots backend for the portal — handles `ScreenCast` and `Screenshot` interfaces |

After installing, enable the audio session services:

```bash
systemctl --user enable --now wireplumber pipewire-pulse
```

wlroots is vendored as a subtree and built from source, so it does not need to be installed as a system package. On Ubuntu, meson will automatically download and build any dependencies (like wayland and pixman) that are too old in the system packages.

## Building waylock

waylock requires Zig to build. Pin to Zig **0.15.x** — the upstream master targets Zig 0.16 which is not yet packaged on Arch.

```bash
make waylock-install
```

This builds waylock, installs the binary to `/usr/bin/waylock`, sets the **setuid root** bit (required for PAM to read `/etc/shadow`), and installs `/etc/pam.d/waylock`.

The PAM config intentionally bypasses `pam_faillock` — using `system-auth` would lock your account after 3 wrong attempts, leaving you unable to unlock until the timeout expires.

Lock the screen with **Alt+Ctrl+L** or run directly:

```bash
lock-session        # uses $WAYLOCK_VIDEO if set, falls back to plain waylock
```

`swayidle` handles automatic locking — displays turn off after 3 minutes idle, session locks after 5 minutes, and also locks before suspend.

> **Note:** Killing waylock forcefully (e.g. `pkill waylock`) will crash dwl. This is by design in the `ext-session-lock-v1` protocol — the compositor terminates the session to prevent the locker being bypassed. If locked out, switch to a TTY with **Ctrl+Alt+F2**, log in, then run `loginctl unlock-session <id>` or reboot cleanly.

## Building dwl, somebar, someblocks, st, dmenu, tabbed, surf

Personal configs live at the repo root and must be symlinked before building:

| File | Symlink target |
|---|---|
| `dwl-config.h` | `dwl/config.h` |
| `somebar-config.hpp` | `somebar/src/config.hpp` |
| `st-config.h` | `st/config.h` |
| `dmenu-config.h` | `dmenu/config.h` |
| `tabbed-config.h` | `tabbed/config.h` |
| `surf-config.h` | `surf/config.h` |

The `install` make target handles everything:

```bash
make install
```

This builds wlroots to a local prefix (`wlroots/install/`), symlinks all configs, then builds and installs dwl, somebar, someblocks, st, dmenu, tabbed, and surf.

> **Note:** `blocks.h` is compiled into the someblocks binary — it is not read at runtime. After editing `blocks.h` or the block scripts' hide/show logic, re-run `make dwl-install` to rebuild. Also avoid having a stale `~/.local/bin/someblocks`; it will shadow the system-wide binary installed by `sudo make install` and changes won't take effect.


## Machine-local session environment

`~/.config/dwl/env` is sourced by `startdwl` before launching the compositor. It is not committed to this repo — use it for machine-specific values:

```bash
# ~/.config/dwl/env
export WAYLOCK_VIDEO="$HOME/Videos/lockscreen-1920x1080@25fps.bgra"
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
```

The PATH extension is important: DWL's keybinding spawns inherit the compositor's environment, which only has the system PATH. Tools installed to `~/.local/bin` (like `tmux-sessionizer`) won't be found without it.

## Screen sharing (Google Meet, Zoom, etc.)

Screen sharing on Wayland requires `xdg-desktop-portal-wlr` to handle the `ScreenCast` portal interface. It starts automatically via D-Bus activation when needed — no manual service management required — but two one-time setup steps are needed.

**1. `~/.config/xdg-desktop-portal/portals.conf`** — tells `xdg-desktop-portal` which backend handles each interface. Without this, the portal falls back to gtk for everything and never uses wlr for screen capture:

```ini
[preferred]
default=gtk
org.freedesktop.impl.portal.ScreenCast=wlr
org.freedesktop.impl.portal.Screenshot=wlr
```

**2. `~/.config/chrome-flags.conf`** — Chrome must run natively on Wayland (not via XWayland) to use PipeWire for screen capture. Without `--ozone-platform=wayland`, only tab sharing works (Chrome handles that internally without the portal):

```
--ozone-platform=wayland
--enable-features=WebRTCPipeWireCapturer
```

`startdwl` exports `WAYLAND_DISPLAY` to the systemd user environment via `dbus-update-activation-environment --systemd`, which satisfies the `ConditionEnvironment=WAYLAND_DISPLAY` check on `xdg-desktop-portal-wlr.service` and allows it to start on demand.

## X11 apps (Steam, surf, etc.)

Xwayland is started automatically on `:1` when dwl launches. `DISPLAY` and `XAUTHORITY` are propagated to D-Bus-activated services via `dbus-update-activation-environment`, so X11 apps work without any manual setup:

```bash
steam
surf
```

surf is patched with the following:

- Force GTK X11 backend via `gdk_set_allowed_backends("x11")` — no `GDK_BACKEND` env var needed
- History patch — visited URLs are appended to `~/.surf/history.txt` with ISO 8601 timestamps; use dmenu to search with `Ctrl+h` (or pipe the file manually)

No additional configuration needed after `make install` and a session restart.

## tmux-sessionizer

A project/session picker powered by fzf (terminal) or dmenu (GUI). Lists directories under `~/src/` alongside running tmux sessions, then creates or switches to the selected session.

```bash
# Terminal (fzf)
tmux-sessionizer

# GUI (dmenu) — bound to a keybinding in dwl
tmux-sessionizer --gui
```

The `ts` bash alias is a shortcut for `tmux-sessionizer`. The script must be on your PATH — the symlink setup below handles this.

## recorder

A Wayland screen recorder front-end using `wf-recorder`. Presents a dmenu menu to choose between region and fullscreen capture, then records to `~/Videos/Screencaps/` as VP9 MKV with audio. A persistent notification appears during recording with a **Stop Recording** action button — clicking it sends SIGTERM to the specific wf-recorder instance.

**Dependencies:** `wf-recorder` (at `~/bin/wf-recorder`), `slurp`, `dmenu`, `libnotify`

```bash
recorder
```

## Creating symlinks

Back up any existing configs, then create symlinks:

```bash
# From the dotfiles repo root
ln -s "$(pwd)/waybar-work" ~/.config/waybar
ln -s "$(pwd)/sway-work" ~/.config/sway
ln -s "$(pwd)/nvim" ~/.config/nvim
ln -s "$(pwd)/tmux" ~/.config/tmux
ln -s "$(pwd)/tofi" ~/.config/tofi
ln -s "$(pwd)/foot" ~/.config/foot
ln -s "$(pwd)/bashrc" ~/.bashrc
mkdir -p ~/.local/bin
ln -s "$(pwd)/sessionizer/tmux-sessionizer" ~/.local/bin/tmux-sessionizer
```

**Note:** The tmux directory only contains `tmux.conf`. After symlinking, install tpm and plugins:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
# Then press prefix + I inside tmux to install plugins
```

To remove a symlink without affecting the repo:

```bash
rm ~/.config/waybar  # only removes the symlink, not the directory
```

## Syncing on another machine

```bash
git pull
git submodule update --init --recursive
make remotes
```

## Updating the nvim submodule

```bash
git submodule update --remote --merge nvim
git add nvim
git commit -m "Update nvim submodule reference"
git push
```
