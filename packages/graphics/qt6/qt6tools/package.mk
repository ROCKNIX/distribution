# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="qt6tools"
PKG_MAJOR_VERSION="6.6"
PKG_VERSION="${PKG_MAJOR_VERSION}.1"
PKG_LICENSE="GPLv3"
PKG_SITE="https://download.qt.io"
PKG_URL="${PKG_SITE}/archive/qt/${PKG_MAJOR_VERSION}/${PKG_VERSION}/submodules/qttools-everywhere-src-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="toolchain:host qt6base"
PKG_DEPENDS_TARGET="toolchain qt6tools:host qt6base"
PKG_LONGDESC="QT6 Tools package"

pre_configure_host() {
 PKG_CMAKE_OPTS_HOST+="		-GNinja \
				-DQT_FEATURE_linguist=ON \
				-DQT_FEATURE_qdbus=OFF \
				-DQT_FEATURE_qtattributionsscanner=ON \
				-DQT_FEATURE_qtdiag=ON \
				-DQT_FEATURE_qtplugininfo=ON \
				-DCMAKE_CROSSCOMPILING=OFF"
}

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+="	-GNinja \
				-DQT_HOST_PATH=${PKG_BUILD}/.x86_64-rocknix-linux-gnu \
				-DQT_FEATURE_linguist=ON \
				-DQT_FEATURE_qdbus=ON \
				-DQT_DEBUG_FIND_PACKAGE=ON
				-DQT_FEATURE_qtattributionsscanner=ON \
				-DQT_FEATURE_qtdiag=ON \
				-DQT_FEATURE_qtplugininfo=ON \
				-DQT_BUILD_TESTS_BY_DEFAULT=OFF \
				-DQT_BUILD_EXAMPLES_BY_DEFAULT=OFF \
				-DQT_FEATURE_LinguistTools=OFF"
}


make_host() {
  ninja ${NINJA_OPTS}
}
