# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="qtermwidget"
PKG_VERSION="2.2.0"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/lxqt/qtermwidget"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="A terminal emulator widget for Qt 6."
PKG_DEPENDS_TARGET="toolchain qt6 lxqt-build-tools"
PKG_TOOLCHAIN="cmake"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr

  mkdir -p ${INSTALL}/usr/lib
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/libqtermwidget6.so* ${INSTALL}/usr/lib

  mkdir -p ${INSTALL}/usr/config/qterminal.org/color-schemes
  cp -rf ${PKG_BUILD}/lib/color-schemes/*.colorscheme ${INSTALL}/usr/config/qterminal.org/color-schemes/
}
