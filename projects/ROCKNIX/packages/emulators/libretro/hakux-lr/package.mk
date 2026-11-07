# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="hakux-lr"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/portare-ch/hakuX-lr"
PKG_DEPENDS_TARGET="toolchain zlib"
PKG_LONGDESC="hakuX libretro core"
PKG_TOOLCHAIN="manual"
PKG_VERSION="0.20.0"
PKG_SHA256="776882b734a9590b6d8c99e5db4fe211d3b912588fed9dcdab3b0b4f7fc0667e"
PKG_URL="${PKG_SITE}/releases/download/linux-v${PKG_VERSION}/hakux-${PKG_VERSION}-aarch64.tar.gz"
PKG_SOURCE_DIR="hakux-${PKG_VERSION}"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -p ${PKG_BUILD}/lib/libretro/hakux_libretro.so ${PKG_BUILD}/lib/libretro/hakux_libretro.info \
    ${INSTALL}/usr/lib/libretro
}
