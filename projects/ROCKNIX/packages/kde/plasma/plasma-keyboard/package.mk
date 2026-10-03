# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="plasma-keyboard"
PKG_VERSION="6.7.5"
PKG_SHA256="0dd91212308e6c6999db55b95b5b462cadc2766935272e9caf2f138b9a063788"
PKG_LICENSE="GPL-3.0-only"
PKG_SITE="https://invent.kde.org/plasma/plasma-keyboard"
PKG_URL="https://download.kde.org/stable/plasma/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm kcoreaddons ki18n kcmutils kconfig kcrash libplasma libxkbcommon wayland \
                    wayland-protocols"
PKG_LONGDESC="Plasma on-screen keyboard (KWin input method) based on Qt Virtual Keyboard"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DPKG_CONFIG_ARGN=--define-variable=datarootdir=/usr/share"
