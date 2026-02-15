# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libmali-vulkan"
PKG_LICENSE="mali_driver"
PKG_ARCH="arm aarch64"
PKG_DEPENDS_TARGET="toolchain mesa vulkan-tools vulkan-headers libmali vulkan-wsi-layer"
PKG_TOOLCHAIN="manual"
PKG_LONGDESC="Vulkan Mali drivers for RK3588 soc"

case ${DEVICE} in
  RK3588)
    PKG_VERSION="11759f18e195e89300bcfeb5ada0d977a7851151"
    PKG_SOURCE_NAME="g610-vulkan-mali.tar.gz"
    FILENAME="libmali-valhall-g610-g6p0-wayland-gbm-vulkan.so"
    # This is some weird default? I didn't want to change behavior of rk3588
    APIVER="1.0.5"
    PKG_URL="https://github.com/r3claimer/packages/raw/${PKG_VERSION}/g610-vulkan-mali.tar.gz"
  ;;
  RK3566)
    PKG_VERSION="rk3576"
    PKG_SOURCE_NAME="g52-vulkan-mali.tar.gz"
    FILENAME="libmali-vulkan-g52.so"
    APIVER="1.2.207"
    PKG_URL="https://github.com/sydarn/libmali/releases/download/${PKG_VERSION}/libmali.so.1.9.0.zip"
  ;;
esac

# Need a custom unpack() as --strip-components=1 in extract script strips everything
unpack() {
mkdir -p ${PKG_BUILD}
case ${DEVICE} in
  RK3588)
    tar -xf ${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME} -C ${PKG_BUILD}
  ;;
  RK3566)
    unzip -j ${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME} libmali.so.1.9.0 -d ${PKG_BUILD}
    mv ${PKG_BUILD}/libmali.so.1.9.0 ${PKG_BUILD}/${FILENAME}
  ;;
esac
}

make_target() {
  sed -i "s~@APIVER@~${APIVER}~g" ${PKG_BUILD}/mali.json
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
  mkdir -p ${INSTALL}/usr/share/vulkan/implicit_layer.d
  mkdir -p ${INSTALL}/usr/share/vulkan/icd.d

  cp ${PKG_BUILD}/${FILENAME} ${INSTALL}/usr/lib/
  cp -r ${PKG_BUILD}/mali.json ${INSTALL}/usr/share/vulkan/icd.d

  ln -sfv /usr/lib/${FILENAME} ${INSTALL}/usr/lib/libMaliVulkan.so.1
  ln -sfv /usr/lib/libMaliVulkan.so.1 ${INSTALL}/usr/lib/libMaliVulkan.so
}
