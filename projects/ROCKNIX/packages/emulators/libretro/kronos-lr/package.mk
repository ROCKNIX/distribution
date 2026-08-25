# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kronos-lr"
PKG_VERSION="46e687cb07f4bf8cb1717b0a7b4b48d208d20bb6"
PKG_SHA256="d9f495763ef000d2ddbb71956b56cd1aff67c3c4f8b54bfdbbc7ce2f8d9b1033"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/FCare/Kronos"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain boost zlib"
PKG_LONGDESC="Kronos is a Sega Saturn emulator forked from yabause."
PKG_TOOLCHAIN="make"

case ${ARCH} in
  aarch64) platform="platform=arm64" ;;
  x86_64) platform="" ;;
esac

make_target() {
  make -C ${PKG_BUILD}/yabause/src/libretro/ generate-files CC="${HOSTCC}"
  make -C ${PKG_BUILD}/yabause/src/libretro/ ${platform} HAVE_CDROM=1 FORCE_GLES=0
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/yabause/src/libretro/kronos_libretro.so ${INSTALL}/usr/lib/libretro/kronos_libretro.so
}
