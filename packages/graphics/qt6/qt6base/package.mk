# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="qt6base"
PKG_MAJOR_VERSION="6.6"
PKG_VERSION="${PKG_MAJOR_VERSION}.1"
PKG_LICENSE="GPLv3"
PKG_SITE="https://download.qt.io"
PKG_URL="${PKG_SITE}/archive/qt/${PKG_MAJOR_VERSION}/${PKG_VERSION}/submodules/qtbase-everywhere-src-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain qt6base:host xorgproto"
PKG_LONGDESC="QT6 base package"

pre_configure_host() {
PKG_CMAKE_OPTS_HOST+="
        -GNinja \
        -DFEATURE_gui=ON \
        -DFEATURE_openssl_linked=ON \
        -DFEATURE_concurrent=ON \
        -DFEATURE_xml=ON \
        -DFEATURE_sql=ON \
        -DFEATURE_testlib=ON \
        -DFEATURE_network=ON \
        -DFEATURE_dbus=ON \
        -DFEATURE_icu=OFF \
        -DFEATURE_glib=OFF \
        -DFEATURE_system_pcre2=ON \
        -DFEATURE_system_zlib=ON \
        -DQT_BUILD_TESTS_BY_DEFAULT=OFF \
        -DQT_BUILD_EXAMPLES_BY_DEFAULT=OFF \
        -DCMAKE_CROSSCOMPILING=OFF"
}

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+="
	-GNinja \
        -DQT_HOST_PATH=${PKG_BUILD}/.x86_64-rocknix-linux-gnu \
        -DFEATURE_gui=ON \
	-DFEATURE_concurrent=OFF \
	-DFEATURE_xml=OFF \
	-DFEATURE_sql=OFF \
	-DFEATURE_testlib=OFF \
	-DFEATURE_network=ON \
	-DFEATURE_icu=OFF \
	-DFEATURE_glib=OFF \
	-DFEATURE_system_doubleconversion=OFF \
	-DFEATURE_system_pcre2=ON \
	-DFEATURE_system_zlib=ON \
	-DFEATURE_libudev=ON\
	-DFEATURE_gui=ON \
	-DFEATURE_freetype=ON \
	-DFEATURE_png=ON\
	-DFEATURE_system_png=ON \
	-DFEATURE_gui=ON \
	-DFEATURE_freetype=ON \
	-DFEATURE_vulkan=OFF \
	-DFEATURE_dbus=ON"

}

make_host() {
  ninja ${NINJA_OPTS}
}
