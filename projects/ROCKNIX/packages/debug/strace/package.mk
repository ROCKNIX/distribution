# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="strace"
PKG_LICENSE="BSD"
PKG_SITE="https://strace.io/"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="strace is a diagnostic, debugging and instructional userspace utility"
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-cfg-libs"

case "${DEVICE}" in
  SM8650|SM8550|SM8250|H700)
    PKG_VERSION="6.19"
    PKG_SHA256="e076c851eec0972486ec842164fdc54547f9d17abd3d1449de8b120f5d299143"
    ;;
  RK3399|S922X|RK3566)
    PKG_VERSION="6.18"
    PKG_SHA256="0ad5dcba973a69e779650ef1cb335b12ee60716fc7326609895bd33e6d2a7325"
    ;;
  *)
    PKG_VERSION="6.17"
    PKG_SHA256="0a7c7bedc7efc076f3242a0310af2ae63c292a36dd4236f079e88a93e98cb9c0"
    ;;
esac
PKG_URL="https://strace.io/files/${PKG_VERSION}/strace-${PKG_VERSION}.tar.xz"

if [ "${TARGET_ARCH}" = x86_64 -o "${TARGET_ARCH}" = "aarch64" ]; then
  PKG_CONFIGURE_OPTS_TARGET="--enable-mpers=no"
fi
