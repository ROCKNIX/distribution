# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kwin"
PKG_VERSION="6.7.5"
PKG_SHA256="6baa910b732d93c48c90f9c1cc685cc93d0b8de0cdf138c24192c045bc3a48e2"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/plasma/kwin"
PKG_URL="https://download.kde.org/stable/plasma/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="toolchain:host ecm:host qt6:host"
PKG_DEPENDS_TARGET="toolchain qt6 ecm kwin:host kauth kcolorscheme kconfig kcoreaddons kcrash kdbusaddons kglobalaccel \
                    kguiaddons ki18n kidletime kpackage kservice ksvg kwidgetsaddons kwindowsystem kdeclarative kcmutils \
                    knewstuff kxmlgui knotifications knighttime kwayland kdecoration kglobalacceld plasma-activities \
                    kirigami libplasma breeze mesa libepoxy vulkan-headers vulkan-loader wayland wayland-protocols \
                    plasma-wayland-protocols libxkbcommon libcanberra libinput systemd libdrm libxcvt lcms2 \
                    libdisplay-info pipewire libevdev libxcb libxcb-cursor xcb-util-wm xcb-util-keysyms libX11 libXi \
                    xwayland"
PKG_LONGDESC="KDE Wayland compositor"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_HOST="-DCMAKE_PREFIX_PATH=${TOOLCHAIN}/usr/local/qt6 \
                     -DCMAKE_CROSSCOMPILING=OFF"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6 \
                       -DPKG_CONFIG_ARGN=--define-variable=datarootdir=/usr/share \
                       -DQTWAYLANDSCANNER_KDE_EXECUTABLE=${TOOLCHAIN}/bin/qtwaylandscanner_kde \
                       -DKWIN_BUILD_X11=ON \
                       -DKWIN_BUILD_SCREENLOCKER=OFF \
                       -DKWIN_BUILD_KCMS=ON \
                       -DKWIN_BUILD_EIS=OFF \
                       -DKWIN_BUILD_GAMECONTROLLER=ON"

pre_configure_host() {
  PKG_CMAKE_SCRIPT="${PKG_BUILD}/src/wayland/tools/CMakeLists.txt"
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
    cp ${PKG_BUILD}/.${HOST_NAME}/qtwaylandscanner_kde ${TOOLCHAIN}/bin
}
