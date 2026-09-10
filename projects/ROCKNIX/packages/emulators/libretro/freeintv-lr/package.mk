# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="freeintv-lr"
PKG_VERSION="ef3e0fe322bec62a7f916c0bb0834c08c348d0b4"
PKG_SHA256="912d0a9c314cc63c396f8bc5a5778c341a3f4f860ebae1e069a877b9c98d0f11"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/FreeIntv"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="FreeIntv is a libretro emulation core for the Mattel Intellivision."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a freeintv_libretro.so ${INSTALL}/usr/lib/libretro
}
