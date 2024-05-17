# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="dos2unix"
PKG_VERSION="7.5.1"
PKG_LICENSE="GPLv3"
PKG_SITE="https://sourceforge.net/projects/dos2unix"
PKG_URL="https://downloads.sourceforge.net/project/${PKG_NAME}/${PKG_NAME}/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="ccache:host"
PKG_LONGDESC="Dos2Unix / Unix2Dos - Text file format converters"

post_unpack() {
  sed -i "s|prefix          = /usr|prefix          = ${TOOLCHAIN}|" ${PKG_BUILD}/Makefile
}
