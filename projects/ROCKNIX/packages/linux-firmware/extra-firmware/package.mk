# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="extra-firmware"
PKG_VERSION="e0d9fb2868f972ea4952fd888aba6bc97acd5810"
PKG_LICENSE="other"
PKG_SITE="http://www.freescale.com"
PKG_URL="https://github.com/ROCKNIX/extra-firmware/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="extra-firmware: Extra kernel firmware needed for ROCKNIX devices"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  case "${DEVICE}" in
    "SM8750")
      mkdir -p ${INSTALL}/$(get_full_firmware_dir)/qca
      mkdir -p ${INSTALL}/$(get_full_firmware_dir)/qcom/vpu
      mkdir -p ${INSTALL}/$(get_full_firmware_dir)/ath12k/WCN7860

      cp -a firmware/ath12k/WCN7860/hw2.0 ${INSTALL}/$(get_full_firmware_dir)/ath12k/WCN7860

      cp -a firmware/qca/gngbtnv10.* ${INSTALL}/$(get_full_firmware_dir)/qca
      cp -a firmware/qca/gngbtnv20.* ${INSTALL}/$(get_full_firmware_dir)/qca
      cp -a firmware/qca/gngbtfw10.* ${INSTALL}/$(get_full_firmware_dir)/qca
      cp -a firmware/qca/gngbtfw20.* ${INSTALL}/$(get_full_firmware_dir)/qca

      cp -a firmware/qcom/gen80000_aqe.fw ${INSTALL}/$(get_full_firmware_dir)/qcom
      cp -a firmware/qcom/gen80000_gmu.bin ${INSTALL}/$(get_full_firmware_dir)/qcom
      cp -a firmware/qcom/gen80000_sqe.fw ${INSTALL}/$(get_full_firmware_dir)/qcom

      cp -a firmware/qcom/sm8750 ${INSTALL}/$(get_full_firmware_dir)/qcom

      cp -a firmware/qcom/vpu/vpu35_p4.mbn ${INSTALL}/$(get_full_firmware_dir)/qcom/vpu
      ;;
  esac
}
