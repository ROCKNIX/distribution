# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="parrot-firmware"
PKG_VERSION="1.0"
PKG_LICENSE="proprietary"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Retroid Pocket Classic vendor firmware blobs"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  FW_TARGET_DIR=${INSTALL}/$(get_full_firmware_dir)
  mkdir -p "${FW_TARGET_DIR}"
  cp -rv ${PKG_DIR}/firmware/* "${FW_TARGET_DIR}/"
}
