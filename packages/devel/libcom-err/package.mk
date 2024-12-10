# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libcom-err"
PKG_VERSION="1.47.0"
PKG_LICENSE="GPL"
PKG_SITE="http://e2fsprogs.sourceforge.net/"
PKG_URL="https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v${PKG_VERSION}/e2fsprogs-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain e2fsprogs"
PKG_LONGDESC="The filesystem utilities for the EXT2 filesystem, including e2fsck, mke2fs, dumpe2fs, fsck, and others."

pre_configure() {
  PKG_CONFIGURE_OPTS_TARGET="BUILD_CC=${HOST_CC} \
                           --with-udev-rules-dir=no \
                           --with-crond-dir=no \
                           --with-systemd-unit-dir=no \
                           --enable-verbose-makecmds \
                           --disable-subset \
                           --enable-elf-shlibs \
                           --disable-bsd-shlibs \
                           --disable-profile \
                           --disable-jbd-debug \
                           --disable-blkid-debug \
                           --disable-testio-debug \
                           --enable-libuuid \
                           --enable-libblkid \
                           --disable-debugfs \
                           --disable-imager \
                           --disable-resizer \
                           --disable-fsck \
                           --disable-e2initrd-helper \
                           --disable-tls \
                           --disable-uuidd \
                           --disable-nls \
                           --disable-rpath \
                           --disable-fuse2fs \
                           --with-gnu-ld"

}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/lib
cp -rf ${PKG_BUILD}/.${TARGET_NAME}/lib/libcom_err.so* ${INSTALL}/usr/lib/
}
