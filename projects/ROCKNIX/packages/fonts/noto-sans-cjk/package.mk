# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="noto-sans-cjk"
PKG_VERSION="2.004"
PKG_LICENSE="OFL-1.1"
PKG_SITE="https://github.com/notofonts/noto-cjk"
PKG_URL="https://raw.githubusercontent.com/notofonts/noto-cjk/Sans${PKG_VERSION}/Sans/OTF/SimplifiedChinese/NotoSansCJKsc-Regular.otf"
PKG_SOURCE_NAME="NotoSansCJKsc-Regular-${PKG_VERSION}.otf"
PKG_SHA256="2c76254f6fc379fddfce0a7e84fb5385bb135d3e399294f6eeb6680d0365b74b"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Noto Sans CJK Simplified Chinese font"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
  cp -f ${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME} ${PKG_BUILD}/NotoSansCJKsc-Regular.otf
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/fonts/truetype/noto-cjk
  cp -f ${PKG_BUILD}/NotoSansCJKsc-Regular.otf \
    ${INSTALL}/usr/share/fonts/truetype/noto-cjk/
}
