# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="melonds-ds-lr"
PKG_VERSION="bc4e4b67d2d470d7c682810a1e892cafd6f9082b"
PKG_SHA256="40faf8f205106a52e86fd37c15390d88bf92433329838766c7d87715098b15dc"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/JesseTG/melonds-ds"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
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
