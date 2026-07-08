# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libssc"
PKG_VERSION="fea9c0d9ecb5b8aecdf26554b26c1df6286526df"
PKG_LICENSE="GPLv3"
PKG_SITE="https://codeberg.org/DylanVanAssche/libssc"
PKG_URL="https://codeberg.org/DylanVanAssche/libssc/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libprotobuf-c:host libprotobuf-c libqmi"
PKG_DEPENDS_HOST="toolchain:host"
PKG_LONGDESC="Library for exposing Qualcomm Sensor Core sensors to Linux."
PKG_TOOLCHAIN="meson"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/include
  rm -rf ${INSTALL}/usr/lib/python*
}