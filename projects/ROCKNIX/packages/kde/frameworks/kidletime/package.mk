# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kidletime"
PKG_VERSION="6.30.0"
PKG_SHA256="22873204292ddb757e5a0a57004c57debe1285cd0fd4e796d07e9de2402e60c3"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://invent.kde.org/frameworks/kidletime"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm wayland wayland-protocols plasma-wayland-protocols"
PKG_LONGDESC="KDE monitoring of user activity"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DWITH_WAYLAND=ON \
                       -DWITH_X11=OFF"
