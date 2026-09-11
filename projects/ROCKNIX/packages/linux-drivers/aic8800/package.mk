# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="aic8800"
PKG_VERSION="516e3b087763d80c44f5e3b6d2dd63e0d925c91d"
PKG_SHA256="f79ff9b8b4dfed97c59fe6877b34406bbac042cc1091ada3bb17224fe62f1b39"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/radxa-pkg/aic8800"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="AICSemi AIC8800 USB Wi-Fi 6 + Bluetooth 5.4 driver"
PKG_TOOLCHAIN="make"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  make -C ${PKG_BUILD}/src/USB/driver_fw/drivers/aic8800 \
       KDIR=$(kernel_path) \
       ARCH=${TARGET_KERNEL_ARCH} \
       CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
       modules

  make -C ${PKG_BUILD}/src/USB/driver_fw/drivers/aic_btusb \
       KDIR=$(kernel_path) \
       ARCH=${TARGET_KERNEL_ARCH} \
       CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
       modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/aic8800
    cp ${PKG_BUILD}/src/USB/driver_fw/drivers/aic8800/aic_load_fw/aic_load_fw.ko \
       ${INSTALL}/$(get_full_module_dir)/aic8800
    cp ${PKG_BUILD}/src/USB/driver_fw/drivers/aic8800/aic8800_fdrv/aic8800_fdrv.ko \
       ${INSTALL}/$(get_full_module_dir)/aic8800
    cp ${PKG_BUILD}/src/USB/driver_fw/drivers/aic_btusb/aic_btusb.ko \
       ${INSTALL}/$(get_full_module_dir)/aic8800
}
