# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="cap32-lr"
PKG_VERSION="06ad0da5d003ab8f2359300ebce4cf31d4c55b6e"
PKG_SHA256="15ebb0e6c5efefd224f11bc33cd8ef584fef7c1757102e8df735edbe611f562d"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/libretro-cap32"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="caprice32 4.2.0 libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a cap32_libretro.so ${INSTALL}/usr/lib/libretro
}
