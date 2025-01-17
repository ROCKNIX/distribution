# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)


PKG_NAME="f2fs-tools"
PKG_VERSION="1.16.0"
PKG_LICENSE="GPL"
PKG_SITE="https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git/"
PKG_URL="${PKG_SITE}/snapshot/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libtool e2fsprogs util-linux zlib systemd lzo"
PKG_LONGDESC="Userspace tools for F2FS; a Filesystem designed for NAND flash memory-based storage devices, such as SSD"
PKG_TOOLCHAIN=autotools
