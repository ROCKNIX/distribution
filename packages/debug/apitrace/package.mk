# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="apitrace"
PKG_VERSION="36c7b766b18017e1dcd6359b7d4e685f3e512c29"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/apitrace/apitrace"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain waffle Python3:host"
PKG_LONGDESC="A set of tools to trace, replay, and inspect OpenGL calls"
GET_HANDLER_SUPPORT="git"

PKG_CMAKE_OPTS_TARGET=" -DENABLE_GUI=OFF -DENABLE_EGL=ON -DENABLE_WAFFLE=ON "
