# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="daphne-lr"
PKG_VERSION="b5481bab34a51369b6749cd95f5f889e43aaa23f"
PKG_LICENSE="GPLv2+"
PKG_SITE="https://github.com/libretro/daphne"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="This is a Daphne core"
PKG_TOOLCHAIN="make"

pre_configure_target() {
	export CFLAGS="${CFLAGS} -Wno-use-after-free -Wno-unused-function -Wno-maybe-uninitialized -Wno-unused-variable -Wno-implicit-function-declaration -Wno-builtin-declaration-mismatch -Wno-unknown-pragmas -Wno-pointer-to-int-cast -Wno-pedantic -Wno-error=incompatible-pointer-types"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp daphne_libretro.so ${INSTALL}/usr/lib/libretro/
}

