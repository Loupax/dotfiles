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

Subtrees are regular directories — no special clone steps needed. To sync upstream changes:

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
sudo pacman -S xorg-xwayland xcb-util-icccm swaync meson ninja libxinerama libxft
```

**Ubuntu 24.04:**

```bash
sudo apt-get install -y libinput-dev libxcb-icccm4-dev libpixman-1-dev libdrm-dev \
  libxkbcommon-dev wayland-protocols libseat-dev hwdata libdisplay-info-dev \
  libliftoff-dev libxcb-composite0-dev libxcb-render0-dev libxcb-xinput-dev \
  libxcb-ewmh-dev libxcb-res0-dev xwayland swaync meson ninja-build
```

| Package | Purpose |
|---|---|
| `xorg-xwayland` | X11 compatibility layer — required to run X11 apps (Steam, etc.) |
| `xcb-util-icccm` / `libxcb-icccm4-dev` | Required to build dwl with Xwayland support |
| `swaync` | Notification daemon |
| `meson`, `ninja` | Build system for wlroots and somebar |

wlroots is vendored as a subtree and built from source, so it does not need to be installed as a system package. On Ubuntu, meson will automatically download and build any dependencies (like wayland and pixman) that are too old in the system packages.

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

## X11 apps (Steam, surf, etc.)

Xwayland is started automatically on `:1` when dwl launches. `DISPLAY` and `XAUTHORITY` are propagated to D-Bus-activated services via `dbus-update-activation-environment`, so X11 apps work without any manual setup:

```bash
steam
surf
```

surf is patched to force the GTK X11 backend internally (`gdk_set_allowed_backends("x11")`), so it does not require `GDK_BACKEND=x11` to be set in the environment.

No additional configuration needed after `make install` and a session restart.

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
```

## Updating the nvim submodule

```bash
git submodule update --remote --merge nvim
git add nvim
git commit -m "Update nvim submodule reference"
git push
```
