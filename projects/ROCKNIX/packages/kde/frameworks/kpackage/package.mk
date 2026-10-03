# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kpackage"
PKG_VERSION="6.30.0"
PKG_SHA256="58939af0c553f24963652e10d248e2f8f2b2ca2b87dc26d3220675ed0cf33019"
PKG_LICENSE="LGPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/frameworks/kpackage"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="toolchain:host ecm:host qt6:host karchive:host ki18n:host kcoreaddons:host"
PKG_DEPENDS_TARGET="toolchain qt6 ecm karchive ki18n kcoreaddons kpackage:host"
PKG_LONGDESC="KDE library to load and install packages of non-binary files"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_HOST="-DBUILD_TESTING=OFF \
                     -DBUILD_QCH=OFF \
                     -DKF_SKIP_PO_PROCESSING=ON \
                     -DKDE_INSTALL_LIBDIR=lib \
                     -DCMAKE_PREFIX_PATH=${TOOLCHAIN}/usr/local/qt6 \
                     -DUSE_DBUS=OFF"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6"
