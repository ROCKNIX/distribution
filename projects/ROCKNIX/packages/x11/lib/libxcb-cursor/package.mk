# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libxcb-cursor"
PKG_VERSION="7b0fa99aa13084a9bf7be4180066f6a74b0adef1" #0.1.6
PKG_LICENSE="OSS"
PKG_SITE="https://gitlab.freedesktop.org/xorg/lib/libxcb-cursor"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain xcb-proto libxcb xcb-util-renderutil xcb-util-image"
PKG_LONGDESC="Port of libXcursor."
PKG_BUILD_FLAGS="+pic"
PKG_TOOLCHAIN="autotools"
