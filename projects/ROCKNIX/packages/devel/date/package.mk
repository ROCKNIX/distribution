# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="date"
PKG_VERSION="3.0.4"
PKG_SHA256="56e05531ee8994124eeb498d0e6a5e1c3b9d4fccbecdf555fe266631368fb55f"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/HowardHinnant/date"
PKG_URL="${PKG_SITE}/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Howard Hinnant's date and time library based on C++11/14/17 <chrono>"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_TZ_LIB=OFF \
                       -DENABLE_DATE_TESTING=OFF"
