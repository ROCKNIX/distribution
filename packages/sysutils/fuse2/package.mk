# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="fuse2"
PKG_VERSION="2.9.9"
PKG_SHA256="d0e69d5d608cc22ff4843791ad097f554dd32540ddc9bed7638cc6fea7c1b4b5"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libfuse/libfuse/"
PKG_URL="https://github.com/libfuse/libfuse/releases/download/fuse-${PKG_VERSION}/fuse-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_DEPENDS_INIT="toolchain fuse2"
PKG_LONGDESC="FUSE provides a simple interface for userspace programs to export a virtual filesystem to the Linux kernel."
# fuse fails to build with GOLD linker on gcc-4.9
PKG_BUILD_FLAGS="-gold"
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="MOUNT_FUSE_PATH=/usr/sbin \
                           UDEV_RULES_PATH=/usr/lib/udev \
                           --enable-lib \
                           --enable-util \
                           --disable-example \
                           --enable-mtab \
                           --disable-rpath \
                           --with-gnu-ld"

pre_configure_init() {
  : # reuse pre_configure_target()
}

post_configure_init() {
  : # reuse post_configure_target()
}

configure_init() {
  : # reuse configure_target()
}

make_init() {
  : # reuse make_target()
}

makeinstall_init() {
  mkdir -p ${INSTALL}/usr/lib
    cp ../.${TARGET_NAME}/lib/.libs/libfuse.so.2 ${INSTALL}/usr/lib/
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/{bin,sbin}
}
