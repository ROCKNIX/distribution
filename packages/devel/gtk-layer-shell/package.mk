# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Your Name (Your GitHub URL)

PKG_NAME="gtk-layer-shell"
PKG_VERSION="0.8.2"
PKG_SHA256="254dd246303127c5d5236ea640f01a82e35d2d652a48d139dd669c832a0f0dce"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/wmww/gtk-layer-shell"
PKG_URL="https://github.com/wmww/gtk-layer-shell/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_URL="https://github.com/wmww/gtk-layer-shell/archive/v${PKG_VERSION}/gtk-layer-shell-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="Python3 gtk3 glib wayland-protocols" # Add dependencies here
PKG_LONGDESC="gtk-layer-shell provides a way to manage windows using Wayland's layer shell protocol."

PKG_MESON_OPTS_TARGET="-Dexamples=false -Ddocs=false -Dtests=false -Dintrospection=false -Dvapi=false"
