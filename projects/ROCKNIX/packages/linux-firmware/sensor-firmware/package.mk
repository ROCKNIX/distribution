# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="sensor-firmware"
PKG_VERSION="ad572cb6627ee436cb1803bb7fc4ae86a9ea9003"
PKG_LICENSE="proprietary"
PKG_SITE="https://github.com/ROCKNIX/sensor-firmware"
PKG_URL="https://github.com/ROCKNIX/sensor-firmware/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Extra kernel firmware needed for Qualcomm devices"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/qcom

  case "${DEVICE}" in
    "SM8750") cp -ra devices/SM8750/* ${INSTALL}/usr/share/qcom ;;
  esac
}