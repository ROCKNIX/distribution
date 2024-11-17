# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libmali-vulkan"
PKG_VERSION="11759f18e195e89300bcfeb5ada0d977a7851151"
PKG_LICENSE="mali_driver"
PKG_ARCH="arm aarch64"
PKG_URL="https://github.com/r3claimer/packages/raw/${PKG_VERSION}/g610-vulkan-mali.tar.gz"
PKG_SOURCE_NAME="g610-vulkan-mali.tar.gz"
PKG_DEPENDS_TARGET="toolchain mesa vulkan-tools vulkan-headers libmali vulkan-wsi-layer"
PKG_TOOLCHAIN="manual"
PKG_LONGDESC="Vulkan Mali drivers for RK3588 soc"

# Need a custom unpack() as --strip-components=1 in extract script strips everything
unpack() {
  mkdir -p ${PKG_BUILD}
  tar -xf ${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME} -C ${PKG_BUILD}
}

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
  mkdir -p ${INSTALL}/usr/share/vulkan/implicit_layer.d
  mkdir -p ${INSTALL}/usr/share/vulkan/icd.d

  cp -r ${PKG_BUILD}/libmali-valhall-g610-g6p0-wayland-gbm-vulkan.so ${INSTALL}/usr/lib/
  cp -r ${PKG_BUILD}/mali.json ${INSTALL}/usr/share/vulkan/icd.d

  ln -sfv /usr/lib/libmali-valhall-g610-g6p0-wayland-gbm-vulkan.so ${INSTALL}/usr/lib/libMaliVulkan.so.1
  ln -sfv /usr/lib/libMaliVulkan.so.1 ${INSTALL}/usr/lib/libMaliVulkan.so
}
