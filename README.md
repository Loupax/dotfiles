# dotfiles

Personal configuration files managed as git submodules. Each config lives in its own repository and is linked here for easy setup on new machines.

## Structure

| Submodule | Repository | Symlink target |
|---|---|---|
| `waybar-work/` | [Loupax/waybar-config](https://github.com/Loupax/waybar-config) | `~/.config/waybar` |
| `sway-work/` | [Loupax/sway-config](https://github.com/Loupax/sway-config) | `~/.config/sway` |
| `nvim/` | [Loupax/nvim.lua](https://github.com/Loupax/nvim.lua) | `~/.config/nvim` |
| `tmux/` | [Loupax/tmux-config](https://github.com/Loupax/tmux-config) | `~/.config/tmux` |
| `tofi/` | [Loupax/tofi-config](https://github.com/Loupax/tofi-config) | `~/.config/tofi` |
| `foot/` | [Loupax/foot-config](https://github.com/Loupax/foot-config) | `~/.config/foot` |

### Standalone files

| File | Symlink target |
|---|---|
| `bashrc` | `~/.bashrc` |

## Initial setup

Clone the repo with all submodules:

```bash
git clone --recurse-submodules https://github.com/Loupax/dotfiles.git
cd dotfiles
```

If you already cloned without `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

## Creating symlinks

Back up any existing configs, then create symlinks pointing to the submodule directories:

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

**Note:** The tmux submodule only contains `tmux.conf`. After symlinking, install tpm and plugins:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
# Then press prefix + I inside tmux to install plugins
```

To remove a symlink without affecting the repo:

```bash
rm ~/.config/waybar  # only removes the symlink, not the directory
```

## Updating submodules

### Pull the latest commit for all submodules

```bash
git submodule update --remote --merge
```

### Pull the latest commit for a specific submodule

```bash
git submodule update --remote --merge waybar-work
```

### Record the updated submodule references

After updating, the dotfiles repo will show the submodules as modified. Commit the new references so other machines pick up the same versions:

```bash
git add -A
git commit -m "Update submodule references"
git push
```

## Making changes to a config

Each submodule is a full git repo. Edit files in place, then commit and push from within the submodule:

```bash
cd waybar-work
# make your changes
git add -A
git commit -m "Your change description"
git push
```

Then go back to the dotfiles root and update the submodule reference:

```bash
cd ..
git add waybar-work
git commit -m "Update waybar-work reference"
git push
```

## Syncing on another machine

Pull the latest dotfiles and update all submodules to their recorded commits:

```bash
git pull
git submodule update --init --recursive
```
