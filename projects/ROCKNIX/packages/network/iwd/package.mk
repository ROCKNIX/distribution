# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/network/iwd/package.mk

PKG_VERSION="3.12"
PKG_SHA256="d89a5e45c7180170e19be828f9e944a768c593758094fc57a358d0e7c4cb1a49"

pre_configure_target() {
  export LIBS="-lncurses -ltinfo"
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/lib/systemd/system

  mkdir -p ${INSTALL}/etc/iwd
  case "${DEVICE}" in
    *)      cp -P ${PKG_DIR}/sources/main.conf        ${INSTALL}/etc/iwd/main.conf ;;
  esac

  mkdir -p ${INSTALL}/usr/bin
    cp -P ${PKG_DIR}/scripts/iwd_get-networks ${INSTALL}/usr/bin
}
