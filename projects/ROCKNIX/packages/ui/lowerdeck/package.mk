# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="lowerdeck"
PKG_VERSION="faf3cd5b259f15581dda0e2569a877f3d8d821c0"
PKG_GIT_CLONE_BRANCH="main"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/bulzipke/lowerdeck"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain Python3 SDL2 SDL2_image SDL2_ttf"
PKG_LONGDESC="Touch UI for the second screen of dual-screen handhelds."
PKG_TOOLCHAIN="manual"
GET_HANDLER_SUPPORT="git"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/lowerdeck
  cp -a ${PKG_BUILD}/. ${INSTALL}/usr/share/lowerdeck/

  rm -rf ${INSTALL}/usr/share/lowerdeck/devices
  if [ -d "${PKG_BUILD}/devices/${DEVICE}" ]; then
    cp -rf ${PKG_BUILD}/devices/${DEVICE}/. ${INSTALL}/usr/share/lowerdeck/
  fi
}
