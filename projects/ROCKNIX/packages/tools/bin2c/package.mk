# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="bin2c"
PKG_VERSION="1.1"
PKG_SHA256="b2eef0a7ce77bb853b6496103727ce0614bfb69bc0f134813586ef12d6ae90e3"
PKG_LICENSE="Public Domain"
PKG_SITE="https://sourceforge.net/projects/bin2c"
PKG_URL="http://downloads.sourceforge.net/sourceforge/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.zip"
PKG_DEPENDS_HOST="ccache:host gcc:host"
PKG_LONGDESC="A command line tool to create C files from binary files."
PKG_TOOLCHAIN="manual"

pre_make_host() {
    ### Extract will not correctly extract this package.
    unzip -oq ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.zip -d ${PKG_BUILD}
}

make_host() {
    cd ${PKG_BUILD}/bin2c
    gcc -o bin2c bin2c.c
}

makeinstall_host() {
    cd ${PKG_BUILD}/bin2c
    mkdir -p ${TOOLCHAIN}/usr/bin
    mv bin2c ${TOOLCHAIN}/usr/bin
}
