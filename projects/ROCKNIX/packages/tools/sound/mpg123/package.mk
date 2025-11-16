# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/addons/addon-depends/multimedia-tools-depends/mpg123/package.mk

PKG_DEPENDS_TARGET+=" SDL2 openal-soft"
PKG_BUILD_FLAGS="+pic"

if [ "${PIPEWIRE}" = yes ]; then
  PKG_DEPENDS_TARGET="${PKG_DEPENDS_TARGET} pipewire"
  PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_TARGET} --with-default-audio=pulse --with-audio=pulse"
fi

unset PKG_CONFIGURE_OPTS_TARGET
