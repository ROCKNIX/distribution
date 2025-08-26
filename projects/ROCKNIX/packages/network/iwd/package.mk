# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/network/iwd/package.mk

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
