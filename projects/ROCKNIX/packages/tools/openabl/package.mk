# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="openabl"
PKG_VERSION="1.2"
PKG_SHA256="28cb97d1b387f28ddba28ed57fdc7d8b1c2ac2cdcd26af9c672620d41abddd4f"
PKG_SITE="https://github.com/OpenHandheldCollective/OpenABL"
PKG_URL="https://github.com/OpenHandheldCollective/OpenABL/releases/download/v${PKG_VERSION}/openabl-v${PKG_VERSION}.tar.gz"
PKG_LONGDESC="OpenABL: an open-source alternative boot loader for Qualcomm devices"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader/openabl
    cp -a ${PKG_BUILD}/${DEVICE}/abl_signed-${DEVICE}.elf ${INSTALL}/usr/share/bootloader/openabl/abl_signed-${DEVICE}.elf
    cp -a ${PKG_DIR}/sources/{backup_abl.sh,flash_abl.sh.template,restore_backup_abl.sh} ${INSTALL}/usr/share/bootloader/openabl
    mv ${INSTALL}/usr/share/bootloader/openabl/flash_abl.sh.template ${INSTALL}/usr/share/bootloader/openabl/flash_abl.sh
    sed -i "s/%DEVICE%/${DEVICE}/g" ${INSTALL}/usr/share/bootloader/openabl/flash_abl.sh
}
