# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)
#
# Out-of-tree module: RTL8733BU WiFi/BT power control via rfkill.
# Controls the power enable GPIO so the chip can be fully off when WiFi (and BT) are off.
# Add to ADDITIONAL_DRIVERS in device options.  DTS must have rockchip,rtl8733bu-power node.

PKG_NAME="RTL8733BU-POWER"
PKG_VERSION="1.0.0"
PKG_LICENSE="GPL"
PKG_LONGDESC="RTL8733BU WiFi/BT power control via rfkill (platform driver)"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD} modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp ${PKG_BUILD}/rtl8733bu_power.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}/

  mkdir -p ${INSTALL}/usr/lib/modules-load.d
  cp ${PKG_DIR}/modules-load.d/*.conf ${INSTALL}/usr/lib/modules-load.d/
}
