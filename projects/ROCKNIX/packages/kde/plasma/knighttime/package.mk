# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="knighttime"
PKG_VERSION="6.7.5"
PKG_SHA256="5cb23e736e4be4952e63c855cfb45850e1085d650e67b7cae3cbf9721921cb9f"
PKG_LICENSE="LGPL-2.1-only"
PKG_SITE="https://invent.kde.org/plasma/knighttime"
PKG_URL="https://download.kde.org/stable/plasma/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm kconfig kcoreaddons kdbusaddons kholidays ki18n"
PKG_LONGDESC="Helpers for scheduling the dark-light cycle"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6"
