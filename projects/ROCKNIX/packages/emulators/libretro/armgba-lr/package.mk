# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="armgba-lr"
PKG_VERSION="b1c4a69c99797d93f0f96901b69b9fd7bf7917c3"
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
  mkdir -p ${INSTALL}/usr/share/glsl-shaders/handheld ${INSTALL}/usr/share/slang-shaders/handheld
  cp -r ${PKG_BUILD}/shaders/shaders_glsl/. ${INSTALL}/usr/share/glsl-shaders/handheld/
  cp -r ${PKG_BUILD}/shaders/shaders_slang/. ${INSTALL}/usr/share/slang-shaders/handheld/
}
