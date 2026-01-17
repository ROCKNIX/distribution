# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mako-osd"
PKG_VERSION="b131bc143f6b0f24d650f16bb88a11c7cb011c20"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/emersion/mako"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain cairo wayland sway pango glib mako-notify"
PKG_LONGDESC="Meso - A lightweight notification daemon for Wayland. Works on Sway."
PKG_TOOLCHAIN="meson"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -r  ${PKG_BUILD}/.${TARGET_NAME}/mako ${INSTALL}/usr/bin
  cp -r  ${PKG_BUILD}/.${TARGET_NAME}/makoctl ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin
}
