# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="extra-firmware"
PKG_VERSION="8834a0c80f5b24fee5ed9e18c1560dc48a6f1bd9"
PKG_SHA256="00dcd41f961a8caa5e33a6a9194591a53d835c93df8b60dcd99716ec1524763d"
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
    "SM6450") cp -a SM6450/* ${INSTALL}/$(get_full_firmware_dir) ;;
    "SM8250") cp -a SM8250/* ${INSTALL}/$(get_full_firmware_dir) ;;
    "SM8550") cp -a SM8550/* ${INSTALL}/$(get_full_firmware_dir) ;;
    "SM8650") cp -a SM8650/* ${INSTALL}/$(get_full_firmware_dir) ;;
    "SM8750") cp -a SM8750/* ${INSTALL}/$(get_full_firmware_dir) ;;
    "RK3566") cp -a RK3566/* ${INSTALL}/$(get_full_firmware_dir) ;;
  esac

  # The WCN7860 firmware supports MLO, but does not report it in the QMI
  # phy capabilities ath12k reads. Advertise it through a firmware-2.bin
  # that carries only a timestamp IE and a features IE with
  # ATH12K_FW_FEATURE_MLO set; the images still load from their own files.
  if [ "${DEVICE}" = "SM8750" ]; then
    printf 'QCOM-ATH12K-FW\000\000\000\000\000\000\004\000\000\000\060\204\225\152\001\000\000\000\001\000\000\000\002\000\000\000' \
      > ${INSTALL}/$(get_full_firmware_dir)/ath12k/WCN7860/hw2.0/firmware-2.bin
  fi
}
