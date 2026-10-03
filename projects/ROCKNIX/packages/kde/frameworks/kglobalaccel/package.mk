# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kglobalaccel"
PKG_VERSION="6.30.0"
PKG_SHA256="e532ebd4cbfc8d6d79c6c38c556f1871315fedae8db2b69b574b9c496f171473"
PKG_LICENSE="LGPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/frameworks/kglobalaccel"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm"
PKG_LONGDESC="KDE global desktop keyboard shortcuts"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DWITH_X11=OFF"
