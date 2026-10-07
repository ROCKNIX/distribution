# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mangmi-airy-firmware"
PKG_VERSION=""
PKG_LICENSE="proprietary"
PKG_SITE=""
PKG_URL=""
PKG_LONGDESC="Mangmi Air Y stock GPU zap shader, until it moves to extra-firmware"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir)
  cp -a ${PKG_DIR}/firmware/* ${INSTALL}/$(get_full_firmware_dir)
}
