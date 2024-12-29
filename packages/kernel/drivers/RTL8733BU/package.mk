# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="RTL8733BU"
PKG_VERSION="48ab87b8ffeb0a43dd2d0b108d3cda9112936522"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/wirenboard/rtl8733bu"
PKG_URL="https://github.com/wirenboard/rtl8733bu/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="RTL8733BU driver"
PKG_TOOLCHAIN="make"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  make V=1 \
       ARCH=${TARGET_KERNEL_ARCH} \
       KSRC=$(kernel_path) \
       CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
       CONFIG_POWER_SAVING=y
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/kernel/drivers/net/wireless
    cp *.ko ${INSTALL}/$(get_full_module_dir)/kernel/drivers/net/wireless
}
