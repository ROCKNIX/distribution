# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libdecor"
PKG_VERSION="0.2.5"
PKG_LICENSE="MIT"
PKG_SITE="https://gitlab.freedesktop.org/libdecor/libdecor"
PKG_URL="${PKG_SITE}/-/archive/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain gtk3"
PKG_LONGDESC="libdecor - A client-side decorations library for Wayland clients"
PKG_TOOLCHAIN="meson"
