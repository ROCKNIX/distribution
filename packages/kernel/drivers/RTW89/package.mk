# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="RTW89"
PKG_VERSION="fce040c12fbf93bfd904ded48df60dea2c8d4423"
PKG_ARCH="aarch64 x86_64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/lwfinger/rtw89"
PKG_URL="https://github.com/lwfinger/rtw89/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux linux-firmware"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Realtek RTL8852xx Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="make"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make KSRC=$(kernel_path) KVER=$(kernel_version)
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/kernel/drivers/net/wireless/rtw89
    cp *.ko ${INSTALL}/$(get_full_module_dir)/kernel/drivers/net/wireless/rtw89
}
