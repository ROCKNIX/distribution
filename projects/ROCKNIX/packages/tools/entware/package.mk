# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="entware"
PKG_VERSION=""
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/Entware/Entware"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="entware: A software repository that offers various software programs that can be installed on your device"
PKG_TOOLCHAIN="manual"

post_install() {
  mkdir -p ${INSTALL}/usr/sbin
    cp -P ${PKG_DIR}/scripts/installentware ${INSTALL}/usr/sbin

  enable_service entware.service
}
