# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="grim"
PKG_VERSION="1.4.1"
PKG_SHA256="5ed8e70fcd83a7e203e92d34dbb82a1342d3f13ad98a6b0310cc97e1a9342ded"
PKG_LICENSE="MIT"
PKG_SITE="https://wayland.emersion.fr/grim/"
PKG_URL="https://git.sr.ht/~emersion/grim/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain wayland pixman libpng"
PKG_LONGDESC="Grab images from a Wayland compositor"
