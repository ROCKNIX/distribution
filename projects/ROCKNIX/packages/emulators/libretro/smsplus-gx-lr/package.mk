# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="smsplus-gx-lr"
PKG_VERSION="8a63f82d3c3bbf7215a31f86a4aaa13fb68a579f"
PKG_SHA256="0d78af08f70f69af103502690e6908189c9a70a67993d3a9d4bd3114f8259e46"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/smsplus-gx"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="SMS Plus GX is an enhanced version"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a smsplus_libretro.so ${INSTALL}/usr/lib/libretro
}
