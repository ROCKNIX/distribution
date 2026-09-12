# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/audio/fluidsynth/package.mk

PKG_CMAKE_OPTS_TARGET="-DBUILD_SHARED_LIBS=1 \
                       -DLIB_SUFFIX= \
                       -Denable-libsndfile=1 \
                       -Denable-pkgconfig=1 \
                       -Denable-pipewire=1 \
                       -Denable-pulseaudio=1 \
                       -Denable-systemd=1 \
                       -Denable-readline=0"

pre_configure_target() {
  export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${TOOLCHAIN}/${TARGET_NAME}/lib"
}
