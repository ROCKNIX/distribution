# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="daedalusx64-sa"
PKG_VERSION="f17e9ed86f3806fadeb69abd29c9526ab2d4bd1b"
PKG_SHA256="6a2fd0ac8cb17678ca1f1fd58a8e6cab536c76552e711fb4a1d8fe3941e82b19"
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
