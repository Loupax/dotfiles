# dotfiles

Personal configuration files, symlinked into place. The neovim config and dwl, somebar, and someblocks are git subtrees; everything else is tracked directly.

## Structure

| Path | Symlink target |
|---|---|
| `waybar-work/` | `~/.config/waybar` |
| `sway-work/` | `~/.config/sway` |
| `tmux/` | `~/.config/tmux` |
| `tofi/` | `~/.config/tofi` |
| `foot/` | `~/.config/foot` |
| `bashrc` | `~/.bashrc` |

### Subtrees

| Path | Repository | Branch | Symlink target |
|---|---|---|---|
| `nvim/` | [Loupax/nvim.lua](https://github.com/Loupax/nvim.lua) | main | `~/.config/nvim` |
| `dwl/` | [Loupax/dwl](https://github.com/Loupax/dwl) | main | — |
| `somebar/` | [Loupax/somebar](https://github.com/Loupax/somebar) | master | — |
| `someblocks/` | [Loupax/someblocks](https://github.com/Loupax/someblocks) | master | — |

Subtrees are regular directories — no special clone steps needed. To sync all upstream changes:

```bash
make update
```

To push local changes back to an individual repo:

```bash
git subtree push --prefix=nvim nvim main
git subtree push --prefix=dwl dwl main
git subtree push --prefix=somebar somebar master
git subtree push --prefix=someblocks someblocks master
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

## Building dwl, somebar, someblocks

Personal configs live at the repo root and must be symlinked before building:

| File | Symlink target |
|---|---|
| `dwl-config.h` | `dwl/config.h` |
| `somebar-config.hpp` | `somebar/src/config.hpp` |

The `dwl-install` make target handles everything:

```bash
make dwl-install
```

This symlinks both configs, then builds and installs dwl, somebar, and someblocks.

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
