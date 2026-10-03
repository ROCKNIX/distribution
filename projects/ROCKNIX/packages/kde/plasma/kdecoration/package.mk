# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kdecoration"
PKG_VERSION="6.7.5"
PKG_SHA256="7ff1fe2854ca08a21a1ba47f1b0c97d12ea24f1db618631319cba4023ca53d86"
PKG_LICENSE="LGPL-2.1-only"
PKG_SITE="https://invent.kde.org/plasma/kdecoration"
PKG_URL="https://download.kde.org/stable/plasma/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm ki18n"
PKG_LONGDESC="Plugin based library to create window decorations"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6"
