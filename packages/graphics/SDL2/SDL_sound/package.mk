# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="SDL_sound"
PKG_VERSION="v2.0.4"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/icculus/SDL_sound"
PKG_URL="https://github.com/icculus/SDL_sound/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib SDL2"
PKG_LONGDESC="SDL_sound library"

PKG_CONFIGURE_OPTS_TARGET="--prefix=/usr \
                           --disable-speex \
                           ac_cv_path_SDL2_CONFIG=${SYSROOT_PREFIX}/usr/bin/sdl2-config"

pre_configure_target() {
  export LDFLAGS="${LDFLAGS} -lm"
}

