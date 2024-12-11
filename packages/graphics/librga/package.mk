# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="librga"
PKG_VERSION="v2.2.0-1-b5fb3a6"
PKG_LICENSE="Apache-2.0"
PKG_DEPENDS_TARGET="toolchain libdrm"
PKG_SITE="https://github.com/tsukumijima/librga-rockchip"
PKG_URL="${PKG_SITE}/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="RGA is an independent 2D hardware acceleration userspace driver"
PKG_TOOLCHAIN="meson"

PKG_MESON_OPTS_TARGET="-Dlibdrm=true" # for samples add "-Dlibrga_demo=true"

post_unpack() {
  grep -rl '#define LOCAL_FILE_PATH' ${PKG_BUILD}/samples | xargs -n1 sed -i 's|#define LOCAL_FILE_PATH .*$|#define LOCAL_FILE_PATH "/storage/rga"|'
  sed -i '/utils\/3rdparty\/libdrm/d' ${PKG_BUILD}/meson.build
}
