# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="RTL8723DS"
PKG_VERSION="52e593e8c889b68ba58bd51cbdbcad7fe71362e4"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/lwfinger/rtl8723ds"
PKG_URL="https://github.com/lwfinger/rtl8723ds/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Realtek RTL81xxEU Linux 3.x driver"
PKG_TOOLCHAIN="make"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  make modules \
       ARCH=${TARGET_KERNEL_ARCH} \
       KSRC=$(kernel_path) \
       CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
       CONFIG_POWER_SAVING=y
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/kernel/drivers/net/wireless/
    cp *.ko ${INSTALL}/$(get_full_module_dir)/kernel/drivers/net/wireless/
}
