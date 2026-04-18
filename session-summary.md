# dwl setup session summary

## repos
- ~/src/dotfiles — main repo, contains subtrees:
  - dwl/ (github:Loupax/dwl, branch main)
  - somebar/ (github:Loupax/somebar, branch master)
  - someblocks/ (github:Loupax/someblocks, branch master)
- nvim/ is a submodule

## what we built
dwl = wayland compositor (dwm for wayland)
somebar = status bar (wayland-ipc patch applied — tag clicks work)
someblocks = status block runner (signal-based, instant updates)

## dwl changes
- MODKEY = Super (WLR_MODIFIER_LOGO)
- gruvbox colors, 2px borders
- monitors: DP-3 at 0,0 — eDP-1 at 0,1080
- keyboard: us,de,gr with grp:alt_shift_toggle
- keybindings migrated from sway (Super+Return=term, Super+d=tofi, Super+Shift+q=kill, Super+Shift+e=quit)
- XF86 volume keys, Print screenshot, Super+Ctrl+4 screenshot+save
- wayland-ipc patch applied (manual conflict resolution required)
- keypressmod() writes XKB layout to /tmp/dwl-keyboard-layout + signals someblocks RTMIN+1

## somebar changes
- wayland-ipc patch applied
- tagNames removed from config.hpp (now populated by protocol)
- buttons: ClkTagBar BTN_LEFT=view, BTN_RIGHT=toggleview

## someblocks changes
- signal handler bug fixed (void termhandler() → void termhandler(int _))
- blocks.h: sb-recorder(1s), sb-media(sig3), sb-volume(sig2), sb-network(2s), sb-cpu(2s), sb-memory(2s), sb-battery(30s), sb-lang(sig1), clock(30s)

## startdwl (dotfiles/dwl/startdwl)
- swaybg wallpaper
- somebar + someblocks
- pactl subscribe → pkill -RTMIN+2 someblocks (instant volume)
- playerctl -F status → pkill -RTMIN+3 someblocks (instant media)

## block scripts (dotfiles/dwl/scripts/sb-*)
all read from /proc or system tools, write nothing except state files in /tmp

## install workflow
# dwl: symlink config before building
ln -sf ~/src/dotfiles/dwl-config.h ~/src/dotfiles/dwl/config.h
cd dotfiles/dwl && make && sudo make install

cd dotfiles/someblocks && sudo make install

# somebar: symlink config before building
ln -sf ~/src/dotfiles/somebar/config.hpp ~/src/dotfiles/somebar/src/config.hpp
cd dotfiles/somebar && ninja -C build && sudo ninja -C build install

## open PRs
- github:Loupax/dwl/pull/2 — wayland-ipc + someblocks migration
- github:Loupax/somebar/pull/1 — wayland-ipc patch
- github:Loupax/someblocks/pull/1 — signal fix + blocks config

## pending
- .rej/.orig files in dotfiles/dwl/ to delete and commit
- somebar config.hpp at dotfiles/somebar/config.hpp — symlink to src/config.hpp before building
- ssh-agent: eval $(ssh-agent -s) + ssh-add, add to shell rc
