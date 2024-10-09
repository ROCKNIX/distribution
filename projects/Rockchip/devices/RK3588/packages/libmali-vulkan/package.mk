# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libmali-vulkan"
PKG_VERSION="4632b6e0bc0abda69655f40c8d42ec03972f4183"
PKG_LICENSE="mali_driver"
PKG_ARCH="arm aarch64"
PKG_URL="https://github.com/r3claimer/packages/raw/refs/heads/g610_vulkan/g610-vulkan-mali.tar.gz"
PKG_DEPENDS_TARGET="toolchain mesa vulkan-tools vulkan-headers libmali vulkan-wsi-layer"
PKG_TOOLCHAIN="manual"
PKG_LONGDESC="Vulkan Mali drivers for RK3588 soc"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
  mkdir -p ${INSTALL}/usr/share/vulkan/implicit_layer.d
  mkdir -p ${INSTALL}/usr/share/vulkan/icd.d

  tar -xf ${PKG_BUILD}/g610-vulkan-mali.tar.gz
  cp -r ${PKG_BUILD}/libmali-valhall-g610-g6p0-wayland-gbm-vulkan.so ${INSTALL}/usr/lib/
  cp -r ${PKG_BUILD}/mali.json ${INSTALL}/usr/share/vulkan/icd.d

  ln -sfv /usr/lib/libmali-valhall-g610-g6p0-wayland-gbm-vulkan.so ${INSTALL}/usr/lib/libMaliVulkan.so.1
  ln -sfv /usr/lib/libMaliVulkan.so.1 ${INSTALL}/usr/lib/libMaliVulkan.so
}
