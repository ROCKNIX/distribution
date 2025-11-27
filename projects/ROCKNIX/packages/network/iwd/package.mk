# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/network/iwd/package.mk

PKG_VERSION="3.10"
PKG_SHA256="0cd7dc9b32b9d6809a4a5e5d063b5c5fd279f5ad3a0bf03d7799da66df5cad45"

pre_configure_target() {
  export LIBS="-lncurses -ltinfo"
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/lib/systemd/system

  mkdir -p ${INSTALL}/etc/iwd
    cp -P ${PKG_DIR}/sources/main.conf ${INSTALL}/etc/iwd

  mkdir -p ${INSTALL}/usr/bin
    cp -P ${PKG_DIR}/scripts/iwd_get-networks ${INSTALL}/usr/bin
}
