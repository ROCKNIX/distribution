# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="layer-shell-qt"
PKG_VERSION="v6.4.3"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/KDE/layer-shell-qt"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Layer-Shell-QT is meant for applications to be able to easily use clients based on wlr-layer-shell."
PKG_DEPENDS_TARGET="toolchain qt6 ecm"
PKG_TOOLCHAIN="cmake"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr
  mkdir -p ${INSTALL}/usr/lib
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/bin/libLayerShellQtInterface.so* ${INSTALL}/usr/lib
}
