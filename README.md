# dotfiles

Personal configuration files, symlinked into place. The neovim config is a git submodule (it has its own repo with plugin submodules); everything else is tracked directly.

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

## Initial setup

```bash
git clone --recurse-submodules https://github.com/Loupax/dotfiles.git
cd dotfiles
```

If you already cloned without `--recurse-submodules`:

```bash
git submodule update --init --recursive
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
