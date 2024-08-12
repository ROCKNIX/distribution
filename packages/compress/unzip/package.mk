# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="unzip"
PKG_VERSION="60"
PKG_SHA256="002da7dccff8314cc6077794343990353935efbd3623a3c457ed0d8a0c1fbea1"
PKG_LICENSE="OSS"
PKG_SITE="http://www.info-zip.org/pub/infozip/"
PKG_URL="https://github.com/madler/unzip/archive/0b82c20ac7375b522215b567174f370be89a4b12.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="UnZip is an extraction utility for archives compressed in .zip format."
PKG_TOOLCHAIN="manual"

make_target() {
    make CC=${CC} RANLIB=$RANLIB AR=${AR} STRIP=${STRIP} \
         -f unix/Makefile generic LOCAL_UNZIP="${CFLAGS}"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp unzip ${INSTALL}/usr/bin
    ${STRIP} ${INSTALL}/usr/bin/unzip
}
