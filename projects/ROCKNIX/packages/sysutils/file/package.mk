# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="file"
PKG_VERSION="5.48"
PKG_SHA256="ed14656883b23a364b4057c05595d93252da9bc473d30106519519d0da141283"
PKG_LICENSE="BSD"
PKG_SITE="http://www.darwinsys.com/file/"
PKG_URL="http://ftp.astron.com/pub/file/file-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="ccache:host autotools:host"
PKG_DEPENDS_TARGET="toolchain file:host zlib"
PKG_LONGDESC="The file utility is used to determine the types of various files."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_HOST="--enable-fsect-man5 --enable-static --disable-shared"
PKG_CONFIGURE_OPTS_TARGET="--enable-fsect-man5 --enable-static --disable-shared"
