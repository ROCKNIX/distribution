# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="melonds-ds-lr"
PKG_VERSION="86986bfd82fb130d4d4739d93159acd986921808"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/JesseTG/melonds-ds"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="An enhanced remake of the melonDS core for libretro that prioritizes standalone parity, reliability, and usability."
PKG_TOOLCHAIN="cmake-make"

PKG_CMAKE_OPTS_TARGET=" -DENABLE_OPENGL=ON"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
  PKG_CMAKE_OPTS_TARGET+=" -DDEFAULT_OPENGL_PROFILE=OpenGL"
elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DDEFAULT_OPENGL_PROFILE=OpenGLES2"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/src/libretro/melondsds_libretro.so ${INSTALL}/usr/lib/libretro/
}
