# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libserialport"
PKG_VERSION="21b3dfe5f68c205be4086469335fd2fc2ce11ed2"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/sigrokproject/libserialport"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A minimal, cross-platform shared library written in C that is intended to take care of the OS-specific details when writing software that uses serial ports."
PKG_TOOLCHAIN="make"

make_target() {
  cd ${PKG_BUILD}
    ./autogen.sh
    ./configure --host=${TARGET_NAME} --with-sysroot=${SYSROOT_PREFIX} --prefix=/usr
}
