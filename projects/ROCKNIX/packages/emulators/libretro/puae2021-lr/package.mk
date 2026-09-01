# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="puae2021-lr"
PKG_VERSION="96ebfcfc2c66233ad37f6dc99ee991211dc719ad"
PKG_SHA256="af671aa1b42eb5b97a05b3ac2e57b6f397f3e17bbd0be7ac204636c2321d3cf0"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/libretro-uae"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="PUAE 2021 libretro port of UAE"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a puae_libretro.so ${INSTALL}/usr/lib/libretro/puae2021_libretro.so
}
