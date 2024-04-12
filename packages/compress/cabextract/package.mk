# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="cabextract"
PKG_VERSION="1.11"
PKG_LICENSE="GPLv3"
PKG_SITE="https://www.cabextract.org.uk"
PKG_URL="https://github.com/ROCKNIX/packages/raw/main/cabextract.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="cabextract is Free Software for extracting Microsoft cabinet file"
PKG_TOOLCHAIN="make"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/lib

  cp -rf ${PKG_BUILD}/usr/bin/* ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/usr/lib/* ${INSTALL}/usr/lib

  chmod +x ${INSTALL}/usr/bin/*
}
