# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="squashfuse"
PKG_VERSION="df85c4ddf1a079b10cfe39a2caf7d0cfdc504a6b"
PKG_SHA256="6ecc2600ced2fadf5a07c71bd12942ab66b8e67d0368a17b9821d75a427ed39a"
PKG_LICENSE="BSD-2-Clause"
PKG_SITE="https://github.com/vasi/squashfuse"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain fuse"
PKG_LONGDESC=" squashfuse - Mount SquashFS archives using FUSE"
PKG_TOOLCHAIN="autotools"
