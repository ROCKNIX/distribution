# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kconfig"
PKG_VERSION="6.30.0"
PKG_SHA256="0e98bac324cd716849202d4b246a948e363d6792a8eb09c78417cdde9559f56e"
PKG_LICENSE="LGPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/frameworks/kconfig"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="toolchain:host ecm:host qt6:host"
PKG_DEPENDS_TARGET="toolchain qt6 ecm kconfig:host"
PKG_LONGDESC="KDE persistent platform-independent application settings"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_HOST="-DBUILD_TESTING=OFF \
                     -DBUILD_QCH=OFF \
                     -DKF_SKIP_PO_PROCESSING=ON \
                     -DKDE_INSTALL_LIBDIR=lib \
                     -DCMAKE_PREFIX_PATH=${TOOLCHAIN}/usr/local/qt6 \
                     -DKCONFIG_USE_GUI=OFF \
                     -DKCONFIG_USE_QML=OFF \
                     -DUSE_DBUS=OFF"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6"
