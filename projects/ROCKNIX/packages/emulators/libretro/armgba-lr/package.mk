# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="armgba-lr"
PKG_VERSION="1eb0d1b0ada3b26d0f2eb1f174a9076aa9b35203"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/Jacob-Matthew-Cook/armGBA"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="armGBA is a Game Boy Advance, Game Boy and Game Boy Color emulator built around a recompiler for ARM and x86 handhelds."
PKG_TOOLCHAIN="cmake"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/armgba_libretro.so ${INSTALL}/usr/lib/libretro/
  cp ${PKG_BUILD}/libretro/armgba_libretro.info ${INSTALL}/usr/lib/libretro/
  mkdir -p ${INSTALL}/usr/share/glsl-shaders/armgba ${INSTALL}/usr/share/slang-shaders/armgba
  cp ${PKG_BUILD}/shaders/*.glsl* ${INSTALL}/usr/share/glsl-shaders/armgba/
  cp ${PKG_BUILD}/shaders/*.slang* ${INSTALL}/usr/share/slang-shaders/armgba/
}
