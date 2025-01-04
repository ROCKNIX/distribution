# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://rocknix.org)
PKG_NAME="waffle"
PKG_LICENSE="BSD"
PKG_VERSION="5f1f48287e806544d745e9a8f5aed47234c61292"
PKG_SITE="https://waffle.freedesktop.org/"
PKG_URL="https://gitlab.freedesktop.org/mesa/waffle/-/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain mesa wayland Python3"
PKG_LONGDESC="Waffle - a library for selecting an OpenGL API and window system at runtime"
PKG_TOOLCHAIN="meson"

PKG_MESON_OPTS_TARGET+=" -Dwayland=enabled \
                       -Dgbm=enabled \
                       -Dx11_egl=enabled \
                       -Dsurfaceless_egl=enabled \
                       -Dglx=enabled \
                       -Dbuild-examples=false"
