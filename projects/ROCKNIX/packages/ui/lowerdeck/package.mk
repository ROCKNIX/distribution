# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="lowerdeck"
PKG_VERSION="ab735114ab318a84e4d28c9c5f1b154e450a579a"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/bulzipke/lowerdeck"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 SDL2 SDL2_image SDL2_ttf"
PKG_LONGDESC="Touch UI for the second screen of dual-screen handhelds."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/lowerdeck
    cp -a ${PKG_BUILD}/* ${INSTALL}/usr/share/lowerdeck
}
