# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="RTL8821AU"
PKG_VERSION="847c74b1c272466f89c77947f7a9703222f0093b"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/morrownr/8821au-20210708"
PKG_URL="https://github.com/morrownr/8821au-20210708/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Realtek 8821AU driver for 4.4-5.x"
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
