# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kguiaddons"
PKG_VERSION="6.30.0"
PKG_SHA256="e98864228d1c5e23f3428025eb9928697374fdc3eddebb3a9dec570de028a62d"
PKG_LICENSE="LGPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/frameworks/kguiaddons"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm wayland wayland-protocols plasma-wayland-protocols"
PKG_LONGDESC="KDE addons to QtGui"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DBUILD_PYTHON_BINDINGS=OFF \
                       -DBUILD_GEO_SCHEME_HANDLER=OFF \
                       -DPKG_CONFIG_ARGN=--define-variable=datarootdir=/usr/share \
                       -DWITH_WAYLAND=ON \
                       -DWITH_X11=OFF"
