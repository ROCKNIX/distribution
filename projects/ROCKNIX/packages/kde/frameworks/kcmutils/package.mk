# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kcmutils"
PKG_VERSION="6.30.0"
PKG_SHA256="0159f80d030ac250b0b353113a55c013ed7e38cb0b678df44d2f0d0b2aca944c"
PKG_LICENSE="LGPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/frameworks/kcmutils"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="toolchain:host ecm:host qt6:host"
PKG_DEPENDS_TARGET="toolchain qt6 ecm kcmutils:host kconfigwidgets kcoreaddons kguiaddons ki18n kio kirigami kitemviews kwidgetsaddons kxmlgui"
PKG_LONGDESC="KDE utilities for System Settings modules"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_HOST="-DBUILD_TESTING=OFF \
                     -DBUILD_QCH=OFF \
                     -DKF_SKIP_PO_PROCESSING=ON \
                     -DKDE_INSTALL_LIBDIR=lib \
                     -DCMAKE_PREFIX_PATH=${TOOLCHAIN}/usr/local/qt6 \
                     -DTOOLS_ONLY=ON"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6"
