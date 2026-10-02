# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

# Temporary TODO
PKG_NAME="sm6450-firmware"
PKG_VERSION="20260922"
PKG_LICENSE="proprietary"
PKG_SITE=""
PKG_URL=""
PKG_LONGDESC="sm6450-firmware: vendor firmware for the TrimUI TG4070 (SG6150)"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir)
    cp -a ${PKG_DIR}/sources/* ${INSTALL}/$(get_full_firmware_dir)
}
