# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libdecor"
PKG_VERSION="0.2.5"
PKG_SHA256="1d0e9b3d2711dfc4edc21db3c87752a76cd62079cfad447699acda5d49b23536"
PKG_LICENSE="MIT"
PKG_SITE="https://gitlab.freedesktop.org/libdecor/libdecor"
PKG_URL="${PKG_SITE}/-/archive/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain gtk3"
PKG_LONGDESC="libdecor - A client-side decorations library for Wayland clients"
PKG_TOOLCHAIN="meson"
