# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="kronos-lr"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/FCare/Kronos"
PKG_ARCH="x86_64 aarch64"
PKG_URL="${PKG_SITE}.git"
PKG_VERSION="46e687cb07f4bf8cb1717b0a7b4b48d208d20bb6"
PKG_GIT_CLONE_BRANCH="extui-align"
PKG_DEPENDS_TARGET="toolchain boost zlib"
PKG_LONGDESC="Kronos is a Sega Saturn emulator forked from yabause."
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"
PKG_PATCH_DIRS+="${DEVICE}"

case ${ARCH} in
  aarch64)
    platform="platform=arm64"
  ;;
  x86_64)
    platform=""
  ;;
esac

make_target() {
  make -C ${PKG_BUILD}/yabause/src/libretro/ generate-files CC="${HOSTCC}"
  make -C ${PKG_BUILD}/yabause/src/libretro/ ${platform} HAVE_CDROM=1 FORCE_GLES=0
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -a ${PKG_BUILD}/yabause/src/libretro/kronos_libretro.so ${INSTALL}/usr/lib/libretro/kronos_libretro.so
}
