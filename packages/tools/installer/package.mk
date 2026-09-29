# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="installer"
PKG_VERSION="1"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="http://libreelec.tv/"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain busybox newt parted e2fsprogs syslinux"
PKG_LONGDESC="LibreELEC.tv Install manager to install the system on any disk"
PKG_TOOLCHAIN="manual"

# grub is only needed for aarch64-EFI devices; GENERIC_X64 (x86_64) uses syslinux
# for both BIOS and UEFI (syslinux ships bootx64.efi), so skip grub there.
if [ "${DEVICE}" != "GENERIC_X64" ]; then
  PKG_DEPENDS_TARGET+=" grub"
fi

post_install() {
  mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_DIR}/scripts/installer ${INSTALL}/usr/bin
    sed -e "s/@DISTRONAME@/${DISTRONAME}/g" \
        -i  ${INSTALL}/usr/bin/installer

  mkdir -p ${INSTALL}/etc
    find_file_path config/installer.conf
    cp ${FOUND_PATH} ${INSTALL}/etc
    sed -e "s/@SYSTEM_SIZE@/${SYSTEM_SIZE}/g" \
        -e "s/@SYSTEM_PART_START@/${SYSTEM_PART_START}/g" \
        -e "s/@SYSLINUX_PARAMETERS@/${SYSLINUX_PARAMETERS}/g" \
        -i ${INSTALL}/etc/installer.conf

  enable_service installer.service
}
