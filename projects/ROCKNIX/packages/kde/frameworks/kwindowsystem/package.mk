# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kwindowsystem"
PKG_VERSION="6.30.0"
PKG_SHA256="639a501b877446b19905399d27e2be2b6ebb0bb481abe3209dc4d535a12e12ca"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://invent.kde.org/frameworks/kwindowsystem"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm wayland wayland-protocols plasma-wayland-protocols libxkbcommon libX11 libxcb xcb-util-keysyms xcb-util-wm"
PKG_LONGDESC="KDE access to the windowing system"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DPKG_CONFIG_ARGN=--define-variable=datarootdir=/usr/share \
                       -DKWINDOWSYSTEM_WAYLAND=ON \
                       -DKWINDOWSYSTEM_X11=ON"
