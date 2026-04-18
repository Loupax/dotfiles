DOTFILES := $(shell pwd)

dwl-install:
	ln -sf $(DOTFILES)/dwl-config.h $(DOTFILES)/dwl/config.h
	ln -sf $(DOTFILES)/somebar/config.hpp $(DOTFILES)/somebar/src/config.hpp
	$(MAKE) -C dwl && sudo $(MAKE) -C dwl install
	meson setup --reconfigure somebar/build somebar
	ninja -C somebar/build && sudo ninja -C somebar/build install
	sudo $(MAKE) -C someblocks install
