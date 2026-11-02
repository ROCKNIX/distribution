# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="pcsx_rearmed-lr"
PKG_VERSION="7b0e8f8fadfbce3d170d195b9d9eecaabfa08c8e"
PKG_SHA256="4f47bd98bac6cdf62dd4f7a56069b0b0d9999aa6800e636334d1788c5cf38ccf"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/pcsx_rearmed"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="ARM optimized PCSX fork"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro -C .. GIT_VERSION=${PKG_VERSION} platform=$(if [ "${TARGET_ARCH}" = "x86_64" ]; then echo unix; else echo ${DEVICE}; fi)"

post_unpack() {
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    case ${TARGET_ARCH} in
      aarch64|x86_64) cp -a ../pcsx_rearmed_libretro.so ${INSTALL}/usr/lib/libretro ;;
      arm) cp -a ../pcsx_rearmed_libretro.so ${INSTALL}/usr/lib/libretro/pcsx_rearmed32_libretro.so ;;
    esac
    if [ "${TARGET_ARCH}" = "aarch64" ] && [ "${ENABLE_32BIT}" = "true" ]; then
      cp -a ${ROOT}/build.${DISTRO}-${DEVICE}.arm/install_pkg/${PKG_NAME}-*/usr/lib/libretro/pcsx_rearmed32_libretro.so ${INSTALL}/usr/lib/libretro
    fi
}
