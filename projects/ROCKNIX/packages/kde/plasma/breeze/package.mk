# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="breeze"
PKG_VERSION="6.7.5"
PKG_SHA256="aa05c0c31c852ed5b137327e7798fd763a54c643875d5d8070625475e0af6976"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/plasma/breeze"
PKG_URL="https://download.kde.org/stable/plasma/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm kcmutils kcolorscheme kconfig kconfigwidgets kcoreaddons kguiaddons ki18n kiconthemes kwindowsystem kdecoration"
PKG_LONGDESC="Breeze Qt style, window decoration, colour schemes and cursors"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DBUILD_QT5=OFF \
                       -DWITH_DECORATIONS=ON \
                       -DWITH_WALLPAPERS=ON"

post_makeinstall_target() {
  find ${INSTALL}/usr/share/wallpapers/Next -name "*.png" ! -path "*/contents/images/1440x2960.png" -delete
  rmdir ${INSTALL}/usr/share/wallpapers/Next/contents/images_dark
  safe_remove ${INSTALL}/usr/share/icons/Breeze_Light
}
