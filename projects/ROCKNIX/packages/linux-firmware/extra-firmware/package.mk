# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="extra-firmware"
PKG_VERSION="9f778568661b52972a17c9c313e611060fedd76f"
PKG_LICENSE="proprietary"
PKG_SITE="https://github.com/ROCKNIX/extra-firmware"
PKG_URL="https://github.com/ROCKNIX/extra-firmware/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="extra-firmware: Extra kernel firmware needed for ROCKNIX devices"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  case "${DEVICE}" in
    "SM8750")
      mkdir -p ${INSTALL}/$(get_full_firmware_dir)/ath12k/WCN7860
        cp -a firmware/ath12k/WCN7860/hw2.0 ${INSTALL}/$(get_full_firmware_dir)/ath12k/WCN7860

      mkdir -p ${INSTALL}/$(get_full_firmware_dir)/qca
        cp -a firmware/qca/{gngbtfw20.mbn,gngbtnv20.bin} ${INSTALL}/$(get_full_firmware_dir)/qca

      mkdir -p ${INSTALL}/$(get_full_firmware_dir)/qcom/vpu
        cp -a firmware/qcom/sm8750 ${INSTALL}/$(get_full_firmware_dir)/qcom
        cp -a firmware/qcom/vpu/vpu35_p4.mbn ${INSTALL}/$(get_full_firmware_dir)/qcom/vpu
      ;;
    "SM6115")
      mkdir -p ${INSTALL}/$(get_full_firmware_dir)
        cp -a SM6115/* ${INSTALL}/$(get_full_firmware_dir)/
      ;;
  esac
}
