# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="RTW88"
PKG_VERSION="d046e7636ba04fcc85d0a9d0aff9aadceed50494"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/lwfinger/rtw88"
PKG_URL="https://github.com/lwfinger/rtw88/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="RTW88 downstream driver"
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
