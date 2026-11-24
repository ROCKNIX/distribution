# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="daedalusx64-sa"
PKG_VERSION="580c0c409358db332149fc2903c610449434f8fc"
PKG_SHA256="742db277a7baa017c8ca29712678284081b79ff923496dd17d97b9a0b6067c70"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/DaedalusX64/daedalus"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libfmt SDL2 SDL2_ttf glew mesa glm"
PKG_LONGDESC="DaedalusX64 is a Nintendo 64 emulator for PSP, 3DS, Vita, Linux, macOS and Windows"

if [ "${ARCH}" = "aarch64" ]; then
  PKG_TOOLCHAIN="manual"
else
  PKG_TOOLCHAIN="cmake"
fi

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

post_unpack() {
  sed -i 's|message (${CMAKE_CXX_FLAGS_RELEASE})|message("${CMAKE_CXX_FLAGS_RELEASE}")|g' ${PKG_BUILD}/Source/CMakeLists.txt
}

makeinstall_target() {
  if [ "${ARCH}" = "aarch64" ]; then
    mkdir -p ${INSTALL}
      cp -a ${ROOT}/build.${DISTRO}-${DEVICE}.arm/install_pkg/daedalusx64-sa-${PKG_VERSION}/usr ${INSTALL}
  else
    mkdir -p ${INSTALL}/usr/bin
      cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

    mkdir -p ${INSTALL}/usr/config/DaedalusX64
      cp -a ${PKG_BUILD}/.${TARGET_NAME}/Source/daedalus ${INSTALL}/usr/config/DaedalusX64/daedalus
      cp -a ${PKG_DIR}/config/* ${INSTALL}/usr/config/DaedalusX64
      cp -a ${PKG_BUILD}/Data/* ${INSTALL}/usr/config/DaedalusX64
      cp -a ${PKG_BUILD}/Source/SysGL/HLEGraphics/n64.psh ${INSTALL}/usr/config/DaedalusX64
  fi
}
