# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libkscreen"
PKG_VERSION="6.7.5"
PKG_SHA256="df317e03acfadfcbc68981b78131750103fadf4d5c5df6368c9e91e698677219"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://invent.kde.org/plasma/libkscreen"
PKG_URL="https://download.kde.org/stable/plasma/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm wayland plasma-wayland-protocols libxcb"
PKG_LONGDESC="KDE screen management library and kscreen-doctor"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6"
