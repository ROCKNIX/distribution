# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="cloud-signin-window"
PKG_VERSION=""
PKG_LICENSE="GPL-2.0"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain gtk3 webkitgtk"
PKG_LONGDESC="A single fullscreen web view for cloud provider sign-in. Not a browser: no address bar, no tabs, and navigation refused outside the provider's host."
PKG_TOOLCHAIN="manual"

# -latomic: WebKit uses 128-bit atomics, which gcc leaves to libatomic rather
# than emitting inline. Linking against libwebkit2gtk without it fails on
# __atomic_load_16 and friends, naming WebKit's library as if it were broken.
make_target() {
  ${CC} ${CFLAGS} ${LDFLAGS} \
    ${PKG_DIR}/sources/cloud-signin-window.c \
    -o cloud-signin-window \
    $(${PKG_CONFIG} --cflags --libs gtk+-3.0 webkit2gtk-4.1) \
    -latomic
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp cloud-signin-window ${INSTALL}/usr/bin
}
