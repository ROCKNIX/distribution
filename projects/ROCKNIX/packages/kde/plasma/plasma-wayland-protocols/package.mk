# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="plasma-wayland-protocols"
PKG_VERSION="1.23.0"
PKG_SHA256="16c5ad917bde2ed795942dacba76654819ddc6a1566842325ef34e0b553ef138"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://invent.kde.org/libraries/plasma-wayland-protocols"
PKG_URL="https://download.kde.org/stable/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm"
PKG_LONGDESC="Plasma-specific Wayland protocol extensions"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6"
