# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mkbootimg"
PKG_VERSION="d2bb0af5ba6d3198a3e99529c97eda1be0b5a093"
PKG_LICENSE="GPL"
PKG_SITE="https://android.googlesource.com/platform/system/tools/mkbootimg"
PKG_URL="${PKG_SITE}/+archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="mkbootimg: Creates kernel boot images for Android"
PKG_TOOLCHAIN="manual"
PKG_DEPENDS_HOST="toolchain Python3:host"

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/mkbootimg
    cp -a gki/ mkbootimg.py $TOOLCHAIN/mkbootimg
}

