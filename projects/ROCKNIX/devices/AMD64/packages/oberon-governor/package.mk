# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="oberon-governor"
PKG_VERSION="7e13da6c2cb9f1e0519242b1cb084ef767631a5c"
PKG_SHA256="fabca42fa52dc1c1ef83b8706f946ec919bcd28bc77fd2cb0a2051a3f383c1a9"
PKG_ARCH="x86_64"
PKG_LICENSE="MIT"
PKG_SITE="https://gitlab.com/mothenjoyer69/oberon-governor"
PKG_URL="${PKG_SITE}/-/archive/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libdrm yaml-cpp"
PKG_LONGDESC="GPU clock and voltage governor for the AMD BC-250 (Cyan Skillfish)"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release"
