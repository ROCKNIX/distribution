# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="breeze-icons"
PKG_VERSION="6.30.0"
PKG_SHA256="93866c19791838fc9757b305e010e23bb38cb5f201e4ecc96cc8ef5f1173ebe6"
PKG_LICENSE="LGPL-3.0-or-later"
PKG_SITE="https://invent.kde.org/frameworks/breeze-icons"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="toolchain:host ecm:host qt6:host"
PKG_DEPENDS_TARGET="toolchain qt6 ecm breeze-icons:host"
PKG_LONGDESC="KDE Breeze icon theme"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_HOST="-DBUILD_TESTING=OFF \
                     -DKDE_INSTALL_LIBDIR=lib \
                     -DCMAKE_PREFIX_PATH=${TOOLCHAIN}/usr/local/qt6 \
                     -DINSTALL_HOST_TOOLS=ON \
                     -DSKIP_INSTALL_ICONS=ON \
                     -DWITH_ICONS_LIBRARY=OFF \
                     -DWITH_ICON_GENERATION=OFF"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/bin \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DWITH_ICONS_LIBRARY=OFF \
                       -DWITH_ICON_GENERATION=OFF"
