# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kglobalacceld"
PKG_VERSION="6.7.5"
PKG_SHA256="83e9a4e226e695fe1544cfa19a9659c5f1000be46c669fe3a9e299029c6c2abf"
PKG_LICENSE="LGPL-2.1-only"
PKG_SITE="https://invent.kde.org/plasma/kglobalacceld"
PKG_URL="https://download.kde.org/stable/plasma/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm kconfig kcoreaddons kcrash kdbusaddons kwindowsystem kglobalaccel kservice kio kjobwidgets"
PKG_LONGDESC="Daemon providing global keyboard shortcut functionality"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DWITH_X11=OFF \
                       -Dqdbus_EXECUTABLE=qdbus"
