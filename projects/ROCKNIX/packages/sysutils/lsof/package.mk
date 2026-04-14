# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="lsof"
PKG_VERSION="4.99.6"
PKG_ARCH="aarch64"
PKG_LICENSE="lsof"
PKG_SITE="https://github.com/lsof-org/lsof"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="lsof is a command listing open files."
PKG_TOOLCHAIN="autotools"

pre_make_target() {
  # soelim is part of groff and not available in the build env.
  # lsof.man is only a man page - not needed for the binary.
  # Patch the Makefile to use cat instead.
  sed -i 's|soelim|cat|g' ${PKG_BUILD}/.aarch64-rocknix-linux-gnu/Makefile
}
