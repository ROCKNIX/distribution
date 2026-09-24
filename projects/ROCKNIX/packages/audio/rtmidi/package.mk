# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rtmidi"
PKG_VERSION="6.0.0"
PKG_SHA256="ef7bcda27fee6936b651c29ebe9544c74959d0b1583b716ce80a1c6fea7617f0"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/thestk/rtmidi"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib"
PKG_LONGDESC="A set of C++ classes that provide a common API for realtime MIDI input/output"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DRTMIDI_API_ALSA=ON \
                       -DRTMIDI_API_JACK=OFF \
                       -DRTMIDI_BUILD_TESTING=OFF"
