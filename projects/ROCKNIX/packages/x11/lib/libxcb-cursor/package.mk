# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libxcb-cursor"
PKG_VERSION="c393b71fff76fe8627d0e95c53e756615f84d7a3"
PKG_LICENSE="OSS"
PKG_SITE="https://gitlab.freedesktop.org/xorg/lib/libxcb-cursor"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain xcb-proto libxcb xcb-util-renderutil xcb-util-image"
PKG_LONGDESC="Port of libXcursor."
PKG_BUILD_FLAGS="+pic"
PKG_TOOLCHAIN="autotools"
