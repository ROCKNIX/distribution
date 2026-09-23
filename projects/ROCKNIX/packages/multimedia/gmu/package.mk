# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="gmu"
PKG_VERSION="3aed18be8a50873ccfb31d2b135b0d22442ded59"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/jhe2/gmu"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 opus mpg123 libvorbis flac speex"
PKG_LONGDESC="The Gmu Music Player"
PKG_TOOLCHAIN="configure"

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_PATCH_DIRS+=" vulkan"
fi

configure_target() {
  export LDFLAGS="${LDFLAGS} -lreadline -lncursesw -ltinfow"
  export TARGET_CFLAGS="${TARGET_CFLAGS} -fcommon"
  export SDL2CONFIG=${SYSROOT_PREFIX}/usr/bin/sdl2-config
  cd ${PKG_BUILD}
  ./configure --enable=medialib
}

make_target() {
  # libmodplug is static and built with -ffast-math, so on x86_64 it calls libmvec
  make DEC_modplug_LIBS="-lmodplug -lm"
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/gmu/playlists
  cp -f ${PKG_DIR}/config/* ${INSTALL}/usr/config/gmu

  mkdir -p ${INSTALL}/usr/bin
  cp -f ${PKG_DIR}/scripts/start_gmu.sh ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/start_gmu.sh

  ln -sf /usr/bin/start_gmu.sh "${INSTALL}/usr/config/gmu/playlists/Start Music Player.sh"
}
