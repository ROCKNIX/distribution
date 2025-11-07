# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2023-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="volk"
#PKG_VERSION="1.4.304"
#PKG_SHA256="ab3d4a8ccaeb32652259cdd008399504a41792675b0421d90b67729ee274746f"
PKG_LICENSE="MIT"
PKG_VERSION="8f53cc717f50f142db4736f401d0b61956cd78f9"
PKG_SITE="https://github.com/zeux/volk"
#PKG_URL="https://github.com/zeux/volk/archive/${PKG_VERSION}.tar.gz"
PKG_URL="${PKG_SITE}.git"
GET_HANDLER_SUPPORT="git"
PKG_GIT_CLONE_BRANCH="master"
PKG_DEPENDS_TARGET="toolchain vulkan-headers"
PKG_LONGDESC="Meta loader for Vulkan API"

PKG_CMAKE_OPTS_TARGET="-DVOLK_INSTALL=on"
