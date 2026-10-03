# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="ksvg"
PKG_VERSION="6.30.0"
PKG_SHA256="7b7aba4e9baa88bfb303977e139e8a105b5cd243443029ee773954307b51eb91"
PKG_LICENSE="LGPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/frameworks/ksvg"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm karchive kcolorscheme kconfig kcoreaddons kguiaddons kirigami"
PKG_LONGDESC="KDE library for rendering SVG-based themes with stylesheet recoloring"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6"
