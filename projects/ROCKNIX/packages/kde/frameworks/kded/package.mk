# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="kded"
PKG_VERSION="6.30.0"
PKG_SHA256="0adf6e22300cee74d57e790b5db844f03a1366a4d6315edbaa49174b12bf1861"
PKG_LICENSE="LGPL-2.0-or-later"
PKG_SITE="https://invent.kde.org/frameworks/kded"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain qt6 ecm kconfig kcoreaddons kcrash kdbusaddons kservice"
PKG_LONGDESC="KDE daemon hosting session service modules"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DBUILD_QCH=OFF \
                       -DKF_SKIP_PO_PROCESSING=ON \
                       -DKDE_INSTALL_LIBDIR=lib \
                       -DKDE_INSTALL_QMLDIR=qml \
                       -DKDE_INSTALL_QTPLUGINDIR=plugins \
                       -DKF6_HOST_TOOLING=${TOOLCHAIN}/lib/cmake \
                       -DQT_HOST_PATH=${TOOLCHAIN}/usr/local/qt6"

pre_configure_target() {
  sed -i 's|\$<TARGET_FILE:KF6::kconf_update>|${KDE_INSTALL_FULL_LIBEXECDIR_KF}/kconf_update|' ${PKG_BUILD}/src/CMakeLists.txt
}
