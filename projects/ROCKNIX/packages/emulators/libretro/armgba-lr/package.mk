# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="armgba-lr"
PKG_VERSION="20061e22f3cf36d805e4c48e0a53a0f58802f84a"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/MagnominusGit/armGBA"
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
