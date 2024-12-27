# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rockchip-video"
PKG_VERSION="e0c1904afad0e8d7fa019385c871c0b86263407f"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/stolen/rockchip-video-drivers"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Drivers for Rockchip video IPs"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD} CONFIG_ROCKCHIP_MULTI_RGA=m
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    cp */*.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
}
