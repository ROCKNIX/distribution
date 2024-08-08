# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="font-awesome"
PKG_VERSION="6.5.2"
PKG_SHA256="6392bc956eb3d391c9d7a14e891ce8010226ffc0c75f1338db126f13cb9cb8f4"
PKG_LICENSE="OFL-1.1"
PKG_SITE="https://fontawesome.com/"
PKG_URL="https://use.fontawesome.com/releases/v${PKG_VERSION}/fontawesome-free-${PKG_VERSION}-desktop.zip"

PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Font Awesome is the Internet's icon library and toolkit, used by millions of designers, developers, and content creators."
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
  unzip -q ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.zip -d ${PKG_BUILD}
  mv ${PKG_BUILD}/fontawesome-free-${PKG_VERSION}-desktop/* ${PKG_BUILD}/
  rmdir ${PKG_BUILD}/fontawesome-free-${PKG_VERSION}-desktop
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/fonts/OTF
  cp -rf ${PKG_BUILD}/otfs/*.otf ${INSTALL}/usr/share/fonts/OTF
}
