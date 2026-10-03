# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kwidgetsaddons"
PKG_VERSION="6.30.0"
PKG_SHA256="ab1333c258678caa7562120a1c03bb71779f7232f1a0e75b9525d921dee3e0a3"
PKG_LICENSE="LGPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/frameworks/kwidgetsaddons"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm"
PKG_LONGDESC="KDE large set of desktop widgets"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DBUILD_PYTHON_BINDINGS=OFF"
