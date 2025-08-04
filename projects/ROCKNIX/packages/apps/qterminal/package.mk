# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="qterminal"
PKG_VERSION="2.2.1"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/lxqt/qterminal"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="QTerminal is a lightweight Qt terminal emulator based on QTermWidget."
PKG_DEPENDS_TARGET="toolchain qt6 qtermwidget lxqt-build-tools layer-shell-qt"
PKG_TOOLCHAIN="cmake"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/qterminal ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/qterminal

  mkdir -p ${INSTALL}/usr/config/modules
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/config/modules
  chmod 0755 ${INSTALL}/usr/config/modules/*
}
