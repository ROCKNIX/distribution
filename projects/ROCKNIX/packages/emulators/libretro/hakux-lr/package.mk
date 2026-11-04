# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="hakux-lr"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/portare-ch/hakuX-lr"
PKG_DEPENDS_TARGET="toolchain zlib"
PKG_LONGDESC="hakuX libretro core"
PKG_TOOLCHAIN="manual"

case ${DEVICE} in
  S922X)
    PKG_VERSION="0.18.1-exp.2"
    PKG_SHA256="91bb06c090922e2e68febead60f37f45ebd02f18cd0237f7aac4db22d79ba7a4"
  ;;
  *)
    PKG_VERSION="0.17.0"
    PKG_SHA256="d2be36ee26ee29696ce75928577b1962417ece99735cc082169ef10fffce7532"
  ;;
esac

PKG_URL="${PKG_SITE}/releases/download/linux-v${PKG_VERSION}/hakux-${PKG_VERSION}-aarch64.tar.gz"
PKG_SOURCE_DIR="hakux-${PKG_VERSION}"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -p ${PKG_BUILD}/lib/libretro/hakux_libretro.so ${PKG_BUILD}/lib/libretro/hakux_libretro.info \
    ${INSTALL}/usr/lib/libretro
}
