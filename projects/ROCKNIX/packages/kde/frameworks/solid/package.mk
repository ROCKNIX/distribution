# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="solid"
PKG_VERSION="6.30.0"
PKG_SHA256="bdbfdc9f26b87e12b951097825af2956f2dee3f14c701d780277b69701f2c74e"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://invent.kde.org/frameworks/solid"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm flex:host bison:host util-linux systemd"
PKG_LONGDESC="KDE hardware integration and detection"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DBUILD_DEVICE_BACKEND_imobile=OFF"
