# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mako-osd"
PKG_VERSION="1.11.0"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/emersion/mako"
PKG_URL="${PKG_SITE}/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain cairo wayland sway pango glib mako-notify"
PKG_LONGDESC="Meso - A lightweight notification daemon for Wayland. Works on Sway."
PKG_TOOLCHAIN="meson"


pre_configure_target() {
  export TARGET_CFLAGS="${TARGET_CFLAGS} -Wno-error=unused-but-set-variable"
  export TARGET_CXXFLAGS="${TARGET_CXXFLAGS} -Wno-error=unused-but-set-variable"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -r  ${PKG_BUILD}/.${TARGET_NAME}/mako ${INSTALL}/usr/bin
  cp -r  ${PKG_BUILD}/.${TARGET_NAME}/makoctl ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin
}
