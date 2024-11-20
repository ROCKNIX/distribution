# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="avfs"
PKG_VERSION="1.1.5"
PKG_LICENSE="GPLv2"
PKG_SITE="https://sourceforge.net/projects/avf/"
PKG_URL="${PKG_SITE}/files/avfs/1.1.5/avfs-${PKG_VERSION}.tar.bz2"
PKG_SHA256="ad9f3b64104d6009a058c70f67088f799309bf8519b14b154afad226a45272cf"
PKG_DEPENDS_TARGET="toolchain fuse2"
PKG_DEPENDS_INIT="toolchain fuse2:init"
PKG_LONGDESC="AVFS is a system, which enables all programs to look inside gzip, tar, zip, etc. files \
	     or view remote (ftp, http, dav, etc.) files, without recompiling the programs."
PKG_TOOLCHAIN="configure"

PKG_CONFIGURE_OPTS_TARGET="--disable-library --disable-dav --disable-debug --without-xz --without-zstd --without-lzip"
PKG_CONFIGURE_OPTS_INIT=${PKG_CONFIGURE_OPTS_TARGET}

makeinstall_init() {
  mkdir -p "${INSTALL}/usr/bin"
  cp fuse/avfsd "${INSTALL}/usr/bin"
}
