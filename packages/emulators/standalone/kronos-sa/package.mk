# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kronos-sa"
PKG_VERSION="2.7.0_official_release"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/FCare/Kronos"
PKG_URL="https://github.com/FCare/Kronos/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 boost openal-soft zlib qt6"
PKG_LONGDESC="Kronos is a Sega Saturn emulator forked from yabause."
PKG_TOOLCHAIN="cmake-make"
PKG_PATCH_DIRS+="${DEVICE}"

PKG_CMAKE_OPTS_TARGET="${PKG_BUILD}/yabause "

if [ "${OPENGL_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} libglvnd glfw"
fi

pre_configure_target() {
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/yabause/src/CMakeLists.txt

  PKG_CMAKE_OPTS_TARGET="${PKG_BUILD}/yabause "

  if [ "${OPENGL_SUPPORT}" = yes ]; then
    PKG_CMAKE_OPTS_TARGET+=" -DYAB_WANT_OPENGL=ON"
  fi

  PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                           -DYAB_USE_QT5=ON"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -P ${PKG_BUILD}/src/port/qt/kronos ${INSTALL}/usr/bin/kronos
  cp -P ${PKG_DIR}/scripts/start_kronos.sh ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/kronos/qt
  cp ${PKG_DIR}/config/kronos.ini ${INSTALL}/usr/config/kronos/qt
}
