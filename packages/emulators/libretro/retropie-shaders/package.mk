# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="retropie-shaders"
PKG_VERSION="43eaf9b91857eb8515310c74ae750895d77b20f8"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/RetroPie/common-shaders"
PKG_URL="https://github.com/RetroPie/common-shaders/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain glsl-shaders"
PKG_LONGDESC="Libretro common shaders from retropie"
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  if [ ! -d "${INSTALL}/usr/share/common-shaders" ]; then
    mkdir -p ${INSTALL}/usr/share/common-shaders
  fi
  rsync -a ${BUILD}/${PKG_NAME}-${PKG_VERSION}/* ${INSTALL}/usr/share/common-shaders/
  rm -f ${INSTALL}/usr/share/common-shaders/{Makefile,configure}
}
