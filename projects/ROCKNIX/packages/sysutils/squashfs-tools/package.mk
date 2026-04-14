# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="squashfs-tools"
PKG_VERSION="4.7"
PKG_SHA256="f1605ef720aa0b23939a49ef4491f6e734333ccc4bda4324d330da647e105328"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/plougher/squashfs-tools"
PKG_URL="https://github.com/plougher/squashfs-tools/releases/download/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libarchive lzo lz4 zstd"
PKG_DEPENDS_HOST="ccache:host zlib:host lzo:host zstd:host"
PKG_NEED_UNPACK="$(get_pkg_directory zlib) $(get_pkg_directory lzo) $(get_pkg_directory zstd)"
PKG_LONGDESC="Tools for squashfs, a highly compressed read-only filesystem for Linux."
PKG_TOOLCHAIN="manual"

make_target() {
  make -C squashfs-tools clean
  make -C squashfs-tools \
          unsquashfs
}

make_host() {
  make -C squashfs-tools \
          mksquashfs \
          XZ_SUPPORT=0 \
          LZO_SUPPORT=1 \
          LZ4_SUPPORT=0 \
          ZSTD_SUPPORT=1 \
          XATTR_SUPPORT=0 \
          XATTR_DEFAULT=0 \
          INCLUDEDIR="-I. -I${TOOLCHAIN}/include"
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
  cp squashfs-tools/mksquashfs ${TOOLCHAIN}/bin
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/squashfs-tools/unsquashfs ${INSTALL}/usr/bin/unsquashfs
  chmod 755 ${INSTALL}/usr/bin/unsquashfs
}
