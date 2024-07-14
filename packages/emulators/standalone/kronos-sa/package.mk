# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="kronos-sa"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/FCare/Kronos"
PKG_ARCH="x86_64"
PKG_URL="${PKG_SITE}.git"
PKG_VERSION="400670e78da403ec37a86f23ac6e6c64e641e78e"
PKG_GIT_CLONE_BRANCH="extui-align"
PKG_DEPENDS_TARGET="toolchain SDL2 boost openal-soft zlib qt5"
PKG_LONGDESC="Kronos is a Sega Saturn emulator forked from yabause."
PKG_TOOLCHAIN="cmake-make"
GET_HANDLER_SUPPORT="git"
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
  cp -a ${PKG_BUILD}/src/port/qt/kronos ${INSTALL}/usr/bin/kronos
  cp -a ${PKG_DIR}/scripts/start_kronos.sh ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/start_kronos.sh
  mkdir -p ${INSTALL}/usr/config/kronos/qt
  cp ${PKG_DIR}/config/kronos.ini ${INSTALL}/usr/config/kronos/qt
}
