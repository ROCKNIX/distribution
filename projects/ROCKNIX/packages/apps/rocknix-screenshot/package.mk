# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rocknix-screenshot"
PKG_VERSION="1.0"
PKG_LICENSE="GPLv2"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain grim jq sway"
PKG_LONGDESC="ROCNIX screenshot utility"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/sources/rocknix-screenshot ${INSTALL}/usr/bin
}
