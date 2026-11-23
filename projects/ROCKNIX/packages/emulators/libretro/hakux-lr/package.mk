# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="hakux-lr"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/portare-ch/hakuX-lr"
PKG_DEPENDS_TARGET="toolchain zlib"
PKG_LONGDESC="hakuX libretro core"
PKG_TOOLCHAIN="manual"
PKG_VERSION="0.37.3"
PKG_SHA256="0a71d99ddfc6f4ad2edf26202ffc13def272ef56debbc131cd071a90917ee396"
PKG_URL="${PKG_SITE}/releases/download/linux-v${PKG_VERSION}/hakux-lr-${PKG_VERSION}-aarch64.tar.gz"
PKG_SOURCE_DIR="hakux-lr-${PKG_VERSION}"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -p ${PKG_BUILD}/lib/libretro/hakux-lr_libretro.* ${INSTALL}/usr/lib/libretro
}
