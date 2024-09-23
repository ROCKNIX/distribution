# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mesa-demos"
PKG_VERSION="9.0.0"
PKG_LICENSE="OSS"
PKG_SITE="https://www.mesa3d.org/"
PKG_URL="https://archive.mesa3d.org/demos/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libX11 mesa glu glew gtk3 libdecor gtk3 libXcomposite"
PKG_LONGDESC="Mesa 3D demos - installed are the well known glxinfo and glxgears."
PKG_BUILD_FLAGS="-sysroot"

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_MESON_OPTS_TARGET=" -Dvulkan=enabled"
else
  PKG_MESON_OPTS_TARGET=" -Dvulkan=disabled"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -P src/xdemos/glxdemo ${INSTALL}/usr/bin
    cp -P src/xdemos/glxgears ${INSTALL}/usr/bin
    cp -P src/xdemos/glxinfo ${INSTALL}/usr/bin

  if [ "${VULKAN_SUPPORT}" = "yes" ]; then
    cp -P src/vulkan/vkgears ${INSTALL}/usr/bin
  fi
}
