# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="ecm"
PKG_VERSION="6.30.0"
PKG_SHA256="22c9f7ff930dae7329faebf2942d2424f4a298c43bb3f11e217be6b12f227f6e"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://invent.kde.org/frameworks/extra-cmake-modules"
PKG_URL="https://download.kde.org/stable/frameworks/$(get_pkg_version_maj_min)/extra-cmake-modules-${PKG_VERSION}.tar.xz"
PKG_LONGDESC="KDE Extra CMake Modules"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_HOST="-DBUILD_TESTING=OFF -DBUILD_HTML_DOCS=OFF -DBUILD_MAN_DOCS=OFF -DBUILD_QTHELP_DOCS=OFF"
PKG_CMAKE_OPTS_TARGET="${PKG_CMAKE_OPTS_HOST}"
