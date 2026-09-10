# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="coreutils"
PKG_VERSION="9.4"
PKG_SHA256="ea613a4cf44612326e917201bbbcdfbd301de21ffc3b59b6e5c07e040b275e52"
PKG_LICENSE="GPLv2+"
PKG_SITE="https://www.gnu.org/software/coreutils/"
PKG_URL="https://ftp.gnu.org/gnu/coreutils/coreutils-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="The GNU Core Utilities are the basic file, shell and text manipulation utilities of the GNU operating system."
PKG_TOOLCHAIN="auto"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/.${TARGET_NAME}/src/stdbuf ${INSTALL}/usr/bin/
  cp ${PKG_BUILD}/.${TARGET_NAME}/src/timeout ${INSTALL}/usr/bin/
  cp ${PKG_BUILD}/.${TARGET_NAME}/src/sort ${INSTALL}/usr/bin/
  mkdir -p ${INSTALL}/usr/lib/coreutils
  cp ${PKG_BUILD}/.${TARGET_NAME}/src/libstdbuf.so ${INSTALL}/usr/lib/coreutils/
}
