# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)


PKG_NAME="btrfs-progs"
PKG_VERSION="6.10.1"
PKG_SHA256="ce7f1d1c33bf5b3acd418466e7e412026e435b05f187e779a1c5303ebf1b1f96"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://btrfs.readthedocs.io/"
PKG_URL="https://github.com/kdave/btrfs-progs/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain e2fsprogs util-linux zlib systemd lzo"
PKG_SECTION="tools"
PKG_SHORTDESC="Tools for the btrfs filesystem"
PKG_LONGDESC="Tools for the btrfs filesystem"
PKG_TOOLCHAIN="configure"

PKG_BUILD_FLAGS="-sysroot"

PKG_ADDON_NAME="BTRFS Tools"

PKG_CONFIGURE_OPTS_TARGET="--disable-backtrace \
                           --disable-documentation \
                           --disable-convert \
                           --disable-python"

pre_configure_target() {
  ./autogen.sh
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/sbin/
    cp -P ${PKG_INSTALL}{btrfs,btrfsck,btrfstune,fsck.btrfs,mkfs.btrfs} ${INSTALL}/usr/sbin/
}

