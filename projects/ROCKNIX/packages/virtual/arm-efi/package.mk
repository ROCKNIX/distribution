# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="arm-efi"
PKG_VERSION="1.0"
PKG_LICENSE="GPL"
PKG_SITE="https://rocknix.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="virtual"
PKG_LONGDESC="Meta package for installing arm-efi bootloader"

post_install() {
  BLS_PATH="${INSTALL}/usr/share/bootloader/loader/entries"

  mkdir -p "${BLS_PATH}"
  cat << EOF > "${BLS_PATH}/${DISTRONAME,,}.conf"
title      ${DISTRONAME}
version    ${OS_VERSION}
linux      /${KERNEL_NAME}
options    boot=LABEL=${DISTRO_BOOTLABEL} disk=LABEL=${DISTRO_DISKLABEL} ${EXTRA_CMDLINE}
EOF
}
