# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kxmlgui"
PKG_VERSION="6.30.0"
PKG_SHA256="10fb8a0f7b874248ff60d9a8ee4e1f06a0efcf01b0d34d7635dfff86e848c352"
PKG_LICENSE="LGPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/frameworks/kxmlgui"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm kconfig kconfigwidgets kcoreaddons kglobalaccel kguiaddons ki18n kiconthemes kitemviews kwidgetsaddons"
PKG_LONGDESC="KDE framework for managing menu and toolbar actions"
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
                       -DBUILD_DESIGNERPLUGIN=OFF"
