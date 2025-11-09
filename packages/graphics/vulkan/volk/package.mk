# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2023-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="volk"
PKG_VERSION="6809ca6a7e3f291f3c1d47147f87b1416fcb4992"
GET_HANDLER_SUPPORT="git"
PKG_GIT_CLONE_BRANCH="master"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/zeux/volk"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain vulkan-headers"
PKG_LONGDESC="Meta loader for Vulkan API"

PKG_CMAKE_OPTS_TARGET="-DVOLK_INSTALL=on"
