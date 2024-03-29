# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="g610-mali-csffw"
PKG_VERSION="1.0"
PKG_LICENSE="nonfree"
PKG_ARCH="arm aarch64"
PKG_DEPENDS_TARGET="kernel-firmware"
PKG_TOOLCHAIN="manual"
PKG_LONGDESC="Mali blob needed for RK3588 gpu"
PKG_ACE_FIRMWARE="https://github.com/JeffyCN/mirrors/raw/ca33693a03b2782edc237d1d3b786f94849bed7d/firmware/g610/mali_csffw.bin"

#Panfork needs v
makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir)
  curl -Lo ${INSTALL}/$(get_full_firmware_dir)/mali_csffw.bin ${PKG_ACE_FIRMWARE}
}
