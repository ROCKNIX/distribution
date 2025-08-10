# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="dejavu"
PKG_VERSION="2.37"
PKG_LICENSE="Bitstream"
PKG_SITE="https://sourceforge.net/projects/dejavu/files/dejavu/${PKG_VERSION}"
PKG_URL="${PKG_SITE}/${PKG_NAME}-fonts-ttf-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="The DejaVu fonts are a font family based upon Bitstream Vera v1.10."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/fonts/truetype/dejavu/
  cp -rf ${PKG_BUILD}/ttf/DejaVuSansCondensed.ttf ${INSTALL}/usr/share/fonts/truetype/dejavu/
}
