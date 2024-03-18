# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="mu-lr"
PKG_VERSION="865acf3a2889dfe02863bbfb9c5b3cfee8620c22"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="CC BY-NC 3.0 US"
PKG_SITE="https://git.libretro.com/libretro/Mu"
PKG_URL="${PKG_SITE}/-/archive/${PKG_VERSION}/Mu-${PKG_VERSION}.tar.gz"
PKG_GIT_CLONE_BRANCH="buildbot"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="An emulator for the Palm m515 OS ported to libretro."
PKG_LONGDESC="An emulator for the Palm m515 OS ported to libretro. It is intended to avoid hacks like those used by the POSE emulator, where API calls are intercepted and replaced with those that don't use the actual hardware."

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"

make_target() {
  make -C ${PKG_BUILD}/libretroBuildSystem/
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/libretroBuildSystem/mu_libretro.so ${INSTALL}/usr/lib/libretro/
}
