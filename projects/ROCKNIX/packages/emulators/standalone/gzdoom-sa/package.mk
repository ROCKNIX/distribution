# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="gzdoom-sa"
PKG_VERSION="g4.14.2"
PKG_SHA256="2c4fbb0c5b06787c8a2ade9fbbbe2fa5eaa7c49cf7f62a73627c381f8f890156"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/ZDoom/gzdoom"
PKG_URL="https://github.com/ZDoom/gzdoom/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host SDL2:host zmusic:host libvpx:host libwebp:host"
PKG_DEPENDS_TARGET="toolchain gzdoom-sa:host SDL2 zmusic libvpx libwebp"
PKG_LONGDESC="GZDoom is a modder-friendly OpenGL and Vulkan source port based on the DOOM engine"
PKG_TOOLCHAIN="cmake-make"

pre_configure_host() {
  unset HOST_CMAKE_OPTS
  PKG_CMAKE_OPTS_HOST="-DZMUSIC_LIBRARIES=${TOOLCHAIN}/usr/lib/libzmusic.so \
                       -DZMUSIC_INCLUDE_DIR=${TOOLCHAIN}/usr/include \
                       -DNO_GTK=ON \
                       -DHAVE_VULKAN=OFF \
                       -DHAVE_GLES2=OFF"
}

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release \
                         -DFORCE_CROSSCOMPILE=ON \
                         -DIMPORT_EXECUTABLES=${PKG_BUILD}/.${HOST_NAME}/ImportExecutables.cmake \
                         -DZMUSIC_LIBRARIES=${SYSROOT_PREFIX}/usr/lib/libzmusic.so \
                         -DZMUSIC_INCLUDE_DIR=${SYSROOT_PREFIX}/usr/include \
                         -DNO_GTK=ON"

  ### Enable GLES on devices that don't support OpenGL.
  if [ ! "${OPENGL_SUPPORT}" = "yes" ] || [ ${PREFER_GLES} = "yes" ]; then
    PKG_CMAKE_OPTS_TARGET+=" -DHAVE_GLES2=ON"
  fi

  ### Enable vulkan support on devices that have it available.
  if [ "${VULKAN_SUPPORT}" = "yes" ]; then
    PKG_CMAKE_OPTS_TARGET+=" -DHAVE_VULKAN=ON"
  else
    PKG_CMAKE_OPTS_TARGET+=" -DHAVE_VULKAN=OFF"
  fi
}

makeinstall_host() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/gzdoom ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/start_gzdoom.sh ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/gzdoom
    cp -a ${PKG_DIR}/config/* ${INSTALL}/usr/config/gzdoom
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/*.pk3 ${INSTALL}/usr/config/gzdoom
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/soundfonts ${INSTALL}/usr/config/gzdoom
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/fm_banks ${INSTALL}/usr/config/gzdoom
}
