# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="knewstuff"
PKG_VERSION="6.30.0"
PKG_SHA256="85408768b5c3f4b0b51ee6a14ae73fea263f451404e266e286c55e0c17e44037"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://invent.kde.org/frameworks/knewstuff"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm attica karchive kconfig kcoreaddons ki18n kirigami kpackage kwidgetsaddons"
PKG_LONGDESC="KDE framework for downloading and sharing additional application data"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DBUILD_DESIGNERPLUGIN=OFF"
