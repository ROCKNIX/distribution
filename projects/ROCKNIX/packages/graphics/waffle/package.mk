# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://rocknix.org)
PKG_NAME="waffle"
PKG_LICENSE="BSD"
PKG_VERSION="6b3c46483844faba4dfe7dd90dc2b0cd06e67158"
PKG_SITE="https://waffle.freedesktop.org/"
PKG_URL="https://gitlab.freedesktop.org/mesa/waffle/-/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain wayland mesa Python3"
PKG_LONGDESC="Waffle - a library for selecting an OpenGL API and window system at runtime"
PKG_TOOLCHAIN="meson"

PKG_MESON_OPTS_TARGET+=" -Dwayland=enabled \
                       -Dgbm=enabled \
                       -Dx11_egl=enabled \
                       -Dsurfaceless_egl=enabled \
                       -Dglx=enabled \
                       -Dbuild-examples=false"
