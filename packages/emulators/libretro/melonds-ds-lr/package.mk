# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="melonds-ds-lr"
PKG_VERSION="29954dbe5d924bbf747d5d5b746e5aead40e401e"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/JesseTG/melonds-ds"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="An enhanced remake of the melonDS core for libretro that prioritizes standalone parity, reliability, and usability."
PKG_TOOLCHAIN="cmake-make"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

PKG_CMAKE_OPTS_TARGET=" -DENABLE_OPENGL=ON"

case ${DEVICE} in
  AMD64)
    PKG_CMAKE_OPTS_TARGET+=" -DEFAULT_OPENGL_PROFILE=OpenGL"
  ;;
  *)
    PKG_CMAKE_OPTS_TARGET+=" -DEFAULT_OPENGL_PROFILE=OpenGLES2"
  ;;
esac

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/src/libretro/melondsds_libretro.so ${INSTALL}/usr/lib/libretro/
}
