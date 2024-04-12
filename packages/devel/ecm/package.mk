# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="ecm"
PKG_VERSION="v5.112.0"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/KDE/extra-cmake-modules"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="KDE Extra CMake Modules"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET+=" -DBUILD_TESTING=OFF -DBUILD_HTML_DOCS=OFF -DBUILD_MAN_DOCS=OFF -DBUILD_QTHELP_DOCS=OFF"
