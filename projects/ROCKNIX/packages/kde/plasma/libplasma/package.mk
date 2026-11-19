# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libplasma"
PKG_VERSION="6.8.3"
PKG_SHA256="76f081f2d96c7dccf1f29fa0a301572d0115b0c5bec1b32ede0fea4a45c254c4"
PKG_LICENSE="LGPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/plasma/libplasma"
PKG_URL="https://download.kde.org/stable/plasma/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm kconfig kcoreaddons kglobalaccel kguiaddons ki18n kiconthemes kio kwindowsystem knotifications kpackage kirigami ksvg kcolorscheme plasma-activities plasma-wayland-protocols wayland wayland-protocols"
PKG_LONGDESC="Plasma library and runtime components"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DBUILD_EXAMPLES=OFF \
                       -DPKG_CONFIG_ARGN=--define-variable=datarootdir=/usr/share"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/share/kdevappwizard
}
