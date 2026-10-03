# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kauth"
PKG_VERSION="6.30.0"
PKG_SHA256="60b75e02abc2bfbb247c586e3ab94def7ecd7b4e1ddb8260358951d84d9ea8c9"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://invent.kde.org/frameworks/kauth"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm kcoreaddons"
PKG_LONGDESC="KDE abstraction to system policy and authentication features"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DKAUTH_BACKEND_NAME=FAKE \
                       -DKAUTH_HELPER_BACKEND_NAME=FAKE"
