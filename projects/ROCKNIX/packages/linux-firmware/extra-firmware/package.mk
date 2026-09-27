# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="extra-firmware"
PKG_VERSION="68ee0a5a20938c5fcaf4ed5e2521eeed583c2376"
PKG_SHA256="6d6c0be01b9f0eafccaf6c503c4359937f5847b333211e1b1e6982881b7e0d60"
PKG_LICENSE="proprietary"
PKG_SITE="https://github.com/ROCKNIX/extra-firmware"
PKG_URL="https://github.com/ROCKNIX/extra-firmware/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="extra-firmware: Extra kernel firmware needed for ROCKNIX devices"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir)

  case "${DEVICE}" in
    "SM4450") cp -a SM4450/* ${INSTALL}/$(get_full_firmware_dir) ;;
    "SM6115") cp -a SM6115/* ${INSTALL}/$(get_full_firmware_dir) ;;
    "SM8250") cp -a SM8250/* ${INSTALL}/$(get_full_firmware_dir) ;;
    "SM8550") cp -a SM8550/* ${INSTALL}/$(get_full_firmware_dir) ;;
    "SM8650") cp -a SM8650/* ${INSTALL}/$(get_full_firmware_dir) ;;
    "SM8750") cp -a SM8750/* ${INSTALL}/$(get_full_firmware_dir) ;;
    "RK3566") cp -a RK3566/* ${INSTALL}/$(get_full_firmware_dir) ;;
  esac
}
