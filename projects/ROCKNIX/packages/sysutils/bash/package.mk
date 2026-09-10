# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-2020 Team LibreELEC
# Copyright (C) 2020-present 351ELEC (https://github.com/351ELEC)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="bash"
PKG_VERSION="5.3"
PKG_SHA256="0d5cd86965f869a26cf64f4b71be7b96f90a3ba8b3d74e27e8e9d9d5550f31ba"
PKG_LICENSE="GPL"
PKG_SITE="http://www.gnu.org/software/bash/"
PKG_URL="http://ftp.gnu.org/gnu/bash/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ncurses readline"
PKG_LONGDESC="The GNU Bourne Again shell."

PKG_CONFIGURE_OPTS_TARGET="--with-curses \
                           --enable-readline \
                           --without-bash-malloc \
                           --with-installed-readline"

pre_configure_target() {
  export CFLAGS_FOR_BUILD="${CFLAGS_FOR_BUILD} -std=gnu17"
}

post_install() {
  ln -sf bash ${INSTALL}/usr/bin/sh
  mkdir -p ${INSTALL}/etc
  cat <<EOF >${INSTALL}/etc/shells
/usr/bin/bash
/usr/bin/sh
EOF
  chmod 4755 ${INSTALL}/usr/bin/bash
}
