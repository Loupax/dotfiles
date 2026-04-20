_VERSION = 0.8-dev
VERSION  = `git describe --tags --dirty 2>/dev/null || echo $(_VERSION)`

WLROOTS_DIR = $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../wlroots)
WLROOTS_PKG = $(WLROOTS_DIR)/install/lib/x86_64-linux-gnu/pkgconfig
PKG_CONFIG = PKG_CONFIG_PATH=$(WLROOTS_PKG) pkg-config

# paths
PREFIX = /usr/local
MANDIR = $(PREFIX)/share/man
DATADIR = $(PREFIX)/share

WLR_INCS = `$(PKG_CONFIG) --cflags wlroots-0.19`
WLR_LIBS = -Wl,--disable-new-dtags,-rpath,$(WLROOTS_DIR)/install/lib/x86_64-linux-gnu `$(PKG_CONFIG) --libs wlroots-0.19`

XWAYLAND = -DXWAYLAND
XLIBS = xcb xcb-icccm

# dwl itself only uses C99 features, but wlroots' headers use anonymous unions (C11).
# To avoid warnings about them, we do not use -std=c99 and instead of using the
# gmake default 'CC=c99', we use cc.
CC = cc
