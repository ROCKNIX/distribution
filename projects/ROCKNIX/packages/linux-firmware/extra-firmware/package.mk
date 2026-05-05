# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="extra-firmware"
PKG_VERSION="54a12b8d3963836cfcb7bda0d2df5417b0a1319a"
PKG_LICENSE="proprietary"
PKG_SITE="https://github.com/ROCKNIX/extra-firmware"
PKG_URL="https://github.com/ROCKNIX/extra-firmware/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="extra-firmware: Extra kernel firmware needed for ROCKNIX devices"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir)

  case "${DEVICE}" in
    "SM6115") cp -a SM6115/* ${INSTALL}/$(get_full_firmware_dir) ;;
    "SM8750") cp -a SM8750/* ${INSTALL}/$(get_full_firmware_dir) ;;
  esac
}
