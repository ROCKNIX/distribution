# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="karchive"
PKG_VERSION="6.30.0"
PKG_SHA256="4cf89d91e429d2ece3110e78f7ef7011952b0412cb15011329516b46f21e98e2"
PKG_LICENSE="LGPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/frameworks/karchive"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="toolchain:host ecm:host qt6:host zlib:host"
PKG_DEPENDS_TARGET="toolchain qt6 ecm zlib bzip2 xz openssl zstd"
PKG_LONGDESC="KDE Qt addon providing access to numerous types of archives"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_HOST="-DBUILD_TESTING=OFF \
                     -DBUILD_QCH=OFF \
                     -DKF_SKIP_PO_PROCESSING=ON \
                     -DKDE_INSTALL_LIBDIR=lib \
                     -DCMAKE_PREFIX_PATH=${TOOLCHAIN}/usr/local/qt6 \
                     -DWITH_BZIP2=OFF \
                     -DWITH_LIBLZMA=OFF \
                     -DWITH_LIBZSTD=OFF \
                     -DWITH_OPENSSL=OFF"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DBUILD_PYTHON_BINDINGS=OFF"
