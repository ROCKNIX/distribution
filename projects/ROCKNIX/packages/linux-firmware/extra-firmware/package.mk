# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="extra-firmware"
PKG_VERSION="88b363e67d4f730feb2c3124724d26dfaa88ce76"
PKG_SHA256="1b253d1a79ed9dc6fb6389be804197bb27f11097b0e7146065d0141ea99b2d25"
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
