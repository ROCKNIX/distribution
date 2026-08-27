# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rocknix-abl"
PKG_VERSION="1.1.8"
PKG_SHA256="b217fd8a07acb0346b4704df3805298b2d7025e27fd59a7c11417a6803bab8af"
PKG_ARCH="aarch64"
PKG_SITE="https://github.com/ROCKNIX/abl"
PKG_URL="https://github.com/ROCKNIX/abl/releases/download/v${PKG_VERSION}/rocknix-abl-v${PKG_VERSION}.tar.gz"
PKG_LONGDESC="ROCKNIX ABL."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader/rocknix_abl
    cp -a ${PKG_BUILD}/abl_signed-${DEVICE}.elf ${INSTALL}/usr/share/bootloader/rocknix_abl/abl_signed-${DEVICE}.elf
    cp -a ${PKG_DIR}/sources/* ${INSTALL}/usr/share/bootloader/rocknix_abl
    mv ${INSTALL}/usr/share/bootloader/rocknix_abl/flash_abl.sh.template ${INSTALL}/usr/share/bootloader/rocknix_abl/flash_abl.sh
    sed -i "s/%DEVICE%/${DEVICE}/g" ${INSTALL}/usr/share/bootloader/rocknix_abl/flash_abl.sh
}
