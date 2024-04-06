# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="installer"
PKG_VERSION="1"
PKG_LICENSE="GPL"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain busybox newt parted e2fsprogs syslinux grub"
PKG_LONGDESC="ROCKNIX Install manager to install the system on any disk"
PKG_TOOLCHAIN="manual"

post_install() {
  mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_DIR}/scripts/installer ${INSTALL}/usr/bin
    sed -e "s/@DISTRONAME@/${DISTRONAME}/g" \
        -e "s/@EXTRA_CMDLINE@/${EXTRA_CMDLINE}/g" \
        -i  ${INSTALL}/usr/bin/installer

  chmod +x ${INSTALL}/usr/bin/installer

  mkdir -p ${INSTALL}/etc
    cp ${PKG_DIR}/config/* ${INSTALL}/etc
    sed -e "s/@SYSTEM_SIZE@/${SYSTEM_SIZE}/g" \
        -e "s/@SYSTEM_PART_START@/${SYSTEM_PART_START}/g" \
        -e "s/@SYSLINUX_PARAMETERS@/${SYSLINUX_PARAMETERS}/g" \
        -e "s/@DISTRO_BOOTLABEL@/${DISTRO_BOOTLABEL}/g" \
        -e "s/@DISTRO_DISKLABEL@/${DISTRO_DISKLABEL}/g" \
        -i ${INSTALL}/etc/installer.conf

  enable_service installer.service
}
