# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kio"
PKG_VERSION="6.30.0"
PKG_SHA256="c19cbd4878347b67a9e05ee6541083f51dd90f9e58ee245b4d7634e09f9c04b2"
PKG_LICENSE="LGPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/frameworks/kio"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm kbookmarks kcolorscheme kcompletion kconfig kcoreaddons kcrash kdbusaddons kded kguiaddons ki18n kiconthemes kitemviews kjobwidgets kservice kwidgetsaddons kwindowsystem solid util-linux"
PKG_LONGDESC="KDE network transparent access to files and data"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DBUILD_DESIGNERPLUGIN=OFF \
                       -DWITH_WAYLAND=ON \
                       -DWITH_X11=OFF \
                       -DCMAKE_DISABLE_FIND_PACKAGE_KF6Wallet=ON"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/share/kdevappwizard
}
