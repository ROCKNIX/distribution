# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="melonds-ds-lr"
PKG_VERSION="f394adbacb5722ee97c1b37c8064da9a25818310"
PKG_SHA256="1b377c6d84355b2449e8f31893839fa0b138b51a98bf72edb8bc3ca9169186a6"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/JesseTG/melonds-ds"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="An enhanced remake of the melonDS core for libretro that prioritizes standalone parity, reliability, and usability."
PKG_BUILD_FLAGS="+lto-off"

PKG_CMAKE_OPTS_TARGET=" -DENABLE_OPENGL=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
  PKG_CMAKE_OPTS_TARGET+=" -DDEFAULT_OPENGL_PROFILE=OpenGL"
elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DDEFAULT_OPENGL_PROFILE=OpenGLES2"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/src/libretro/melondsds_libretro.so ${INSTALL}/usr/lib/libretro
}
