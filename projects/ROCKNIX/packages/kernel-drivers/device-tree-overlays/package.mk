# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="device-tree-overlays"
PKG_VERSION="1.0"
PKG_LICENSE="GPL2"
PKG_SITE="https://rocknix.org"
PKG_LONGDESC="device-tree-overlays: ROCKNIX linux device tree overlays"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

make_target() {
  for dts in ${PKG_BUILD}/${DEVICE}/*.dts; do
    $(kernel_path)/scripts/dtc/dtc -@ -I dts -O dtb -o ${dts%.dts}.dtbo ${dts}
  done
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader/overlays
    cp -a ${PKG_BUILD}/${DEVICE}/*.dtbo ${INSTALL}/usr/share/bootloader/overlays

  if [ ${DEVICE} != "RK3326" ]; then
    mkdir -p ${INSTALL}/usr/bin
      cp -a ${PKG_BUILD}/dtb_overlay ${INSTALL}/usr/bin
  fi
}
