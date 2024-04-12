# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="vice-sa"
PKG_VERSION="3.8"
PKG_LICENSE="GPLv2"
PKG_SITE="https://sourceforge.net/projects/vice-emu"
PKG_URL="${PKG_SITE}/files/releases/vice-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain xa:host SDL2 SDL2_image ncurses readline dos2unix:host"
PKG_LONGDESC="Commodore 8-bit Emulator"
PKG_CONFIGURE_OPTS_TARGET+=" --disable-pdf-docs --enable-gtk3ui=no --without-alsa --with-pulse --enable-sdl2ui"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

pre_configure_target() {
  export LDFLAGS="${LDFLAGS} -lreadline -lncursesw -ltinfow"
  export CFLAGS="${CFLAGS} -fcommon"
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/vice
  if [ -d "${PKG_DIR}/configs" ]
  then
    cp -f ${PKG_DIR}/configs/* ${INSTALL}/usr/config/vice
  fi

  for sc in x128 x64sc xplus4 xvic
  do
    cp -f ${PKG_DIR}/sources/start_vice.sh ${INSTALL}/usr/bin/start_${sc}.sh
    sed -i "s~@EMU@~${sc}~g" ${INSTALL}/usr/bin/start_${sc}.sh
  done
  chmod 0755 ${INSTALL}/usr/bin/*
}
