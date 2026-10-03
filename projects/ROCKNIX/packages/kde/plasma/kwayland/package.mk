# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kwayland"
PKG_VERSION="6.7.5"
PKG_SHA256="8d4c83524919dc87b5dec546d0fb14c591c03957888cb7b240a4a9d1bbdc8269"
PKG_LICENSE="LGPL-2.1-only"
PKG_SITE="https://invent.kde.org/plasma/kwayland"
PKG_URL="https://download.kde.org/stable/plasma/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm wayland wayland-protocols plasma-wayland-protocols mesa"
PKG_LONGDESC="Qt-style client library wrapper for the Wayland libraries"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6"
