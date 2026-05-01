DOTFILES := $(shell pwd)
GITHUB := git@github.com:Loupax

remotes:
	git remote set-url dmenu $(GITHUB)/dmenu.git 2>/dev/null || git remote add dmenu $(GITHUB)/dmenu.git
	git remote set-url surf $(GITHUB)/surf.git 2>/dev/null || git remote add surf $(GITHUB)/surf.git
	git remote set-url tabbed $(GITHUB)/tabbed.git 2>/dev/null || git remote add tabbed $(GITHUB)/tabbed.git
	git remote set-url dwl $(GITHUB)/dwl.git 2>/dev/null || git remote add dwl $(GITHUB)/dwl.git
	git remote set-url st $(GITHUB)/st.git 2>/dev/null || git remote add st $(GITHUB)/st.git
	git remote set-url somebar $(GITHUB)/somebar.git 2>/dev/null || git remote add somebar $(GITHUB)/somebar.git
	git remote set-url someblocks $(GITHUB)/someblocks.git 2>/dev/null || git remote add someblocks $(GITHUB)/someblocks.git
	git remote set-url wlroots $(GITHUB)/wlroots.git 2>/dev/null || git remote add wlroots $(GITHUB)/wlroots.git
	git remote set-url waylock $(GITHUB)/waylock.git 2>/dev/null || git remote add waylock $(GITHUB)/waylock.git

update:
	git subtree pull --prefix=dmenu dmenu master --squash
	git subtree pull --prefix=surf surf surf-webkit2 --squash
	git subtree pull --prefix=tabbed tabbed master --squash
	git subtree pull --prefix=dwl dwl main --squash
	git subtree pull --prefix=st st main --squash
	git subtree pull --prefix=somebar somebar master --squash
	git subtree pull --prefix=someblocks someblocks master --squash
	git subtree pull --prefix=wlroots wlroots master --squash
	git subtree pull --prefix=waylock waylock master --squash

push:
	git subtree push --prefix=dmenu dmenu master
	git subtree push --prefix=surf surf surf-webkit2
	git subtree push --prefix=tabbed tabbed master
	git subtree push --prefix=dwl dwl main
	git subtree push --prefix=st st main
	git subtree push --prefix=somebar somebar master
	git subtree push --prefix=someblocks someblocks master
	git subtree push --prefix=wlroots wlroots master
	git subtree push --prefix=waylock waylock master

wlroots-build:
	meson setup --reconfigure --wrap-mode=default --prefix=$(DOTFILES)/wlroots/install --libdir=lib wlroots/build wlroots
	ninja -C wlroots/build
	ninja -C wlroots/build install

dwl-install: wlroots-build
	ln -sf $(DOTFILES)/dwl-config.h $(DOTFILES)/dwl/config.h
	ln -sf $(DOTFILES)/somebar-config.hpp $(DOTFILES)/somebar/src/config.hpp
	$(MAKE) -C dwl && sudo $(MAKE) -C dwl install
	meson setup --reconfigure somebar/build somebar
	ninja -C somebar/build && sudo ninja -C somebar/build install
	sudo $(MAKE) -C someblocks install

st-install:
	ln -sf $(DOTFILES)/st-config.h $(DOTFILES)/st/config.h
	$(MAKE) -C st && sudo $(MAKE) -C st install

dmenu-install:
	ln -sf $(DOTFILES)/dmenu-config.h $(DOTFILES)/dmenu/config.h
	$(MAKE) -C dmenu && sudo $(MAKE) -C dmenu install

tabbed-install:
	ln -sf $(DOTFILES)/tabbed-config.h $(DOTFILES)/tabbed/config.h
	$(MAKE) -C tabbed && sudo $(MAKE) -C tabbed install

surf-install:
	ln -sf $(DOTFILES)/surf-config.h $(DOTFILES)/surf/config.h
	$(MAKE) -C surf && sudo $(MAKE) -C surf install

waylock-install:
	cd waylock && DESTDIR=/tmp/waylock-dest zig build --prefix /usr -Doptimize=ReleaseSafe install
	sudo cp -a /tmp/waylock-dest/. /
	rm -rf /tmp/waylock-dest
	sudo chown root:root /usr/bin/waylock
	sudo chmod u+s /usr/bin/waylock

install: dwl-install st-install dmenu-install tabbed-install surf-install waylock-install
