# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kirigami"
PKG_VERSION="6.30.0"
PKG_SHA256="6de811e559c20dc1086c0cf2c34bb98712dbe4d45f960c62c3c3f887332c95f8"
PKG_LICENSE="LGPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/frameworks/kirigami"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm"
PKG_LONGDESC="KDE QtQuick components for convergent touch and desktop applications"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DBUILD_EXAMPLES=OFF"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/share/kdevappwizard
}
