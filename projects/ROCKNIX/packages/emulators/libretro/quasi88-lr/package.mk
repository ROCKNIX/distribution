# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="quasi88-lr"
PKG_VERSION="b5a0e044a914c9a6b8d7b2dd2ddd152f93d35687"
PKG_SHA256="7cd39760926133dd94cffc597ef558b9c7e505cbccc8e716e82809b2641e9db0"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/libretro/quasi88-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A port of QUASI88, a PC-8800 series emulator by Showzoh Fukunaga, to the libretro API"

pre_configure_target() {
  CFLAGS="${CFLAGS} -std=gnu17"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a quasi88_libretro.so ${INSTALL}/usr/lib/libretro
}
