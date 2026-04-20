DOTFILES := $(shell pwd)

update:
	git subtree pull --prefix=dwl dwl main --squash
	git subtree pull --prefix=somebar somebar master --squash
	git subtree pull --prefix=someblocks someblocks master --squash
	git subtree pull --prefix=wlroots wlroots master --squash

push:
	git subtree push --prefix=dwl dwl main
	git subtree push --prefix=somebar somebar master
	git subtree push --prefix=someblocks someblocks master
	git subtree push --prefix=wlroots wlroots master

wlroots-build:
	meson setup --wrap-mode=default --prefix=$(DOTFILES)/wlroots/install --libdir=lib wlroots/build wlroots
	ninja -C wlroots/build
	ninja -C wlroots/build install

dwl-install: wlroots-build
	ln -sf $(DOTFILES)/dwl-config.h $(DOTFILES)/dwl/config.h
	ln -sf $(DOTFILES)/somebar-config.hpp $(DOTFILES)/somebar/src/config.hpp
	$(MAKE) -C dwl && sudo $(MAKE) -C dwl install
	meson setup --reconfigure somebar/build somebar
	ninja -C somebar/build && sudo ninja -C somebar/build install
	sudo $(MAKE) -C someblocks install

install: dwl-install
