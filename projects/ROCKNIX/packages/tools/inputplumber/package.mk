# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="inputplumber"
PKG_VERSION="5ffb8b44d4daf377b9b0e1d7d1c26c65b7012d4b"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/gio3k/InputPlumber"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd libevdev libiio polkit"
PKG_LONGDESC="Open source input router and remapper daemon for Linux"
PKG_TOOLCHAIN="manual"

make_target() {
  export LD_LIBRARY_PATH="${TOOLCHAIN}/lib"
  export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=${SYSROOT_PREFIX}"

  cargo build \
    --target ${TARGET_NAME} \
    --no-default-features 
}

makeinstall_target() {
  mkdir -p ${INSTALL}
    cp -a ${PKG_BUILD}/rootfs/* ${INSTALL}

  mkdir -p ${INSTALL}/usr/bin
    # TODO: change this from debug to release when this PR is ready to merge
    # release builds take 10 minutes!
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/debug/inputplumber ${INSTALL}/usr/bin
}

post_install() {
  enable_service inputplumber.service
}