# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rocknix-joypad"
PKG_VERSION="e205fe5489561d955dbf00a4e24e73410cdd30f2"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/ROCKNIX/rocknix-joypad"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="rocknix-joypad: ROCKNIX joypad driver"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    cp *.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
}
