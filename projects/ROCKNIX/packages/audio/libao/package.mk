# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libao"
PKG_VERSION="1.2.0"
PKG_SHA256="03ad231ad1f9d64b52474392d63c31197b0bc7bd416e58b1c10a329a5ed89caf"
PKG_LICENSE="GPLv2"
PKG_SITE="https://xiph.org/ao/"
PKG_URL="http://downloads.xiph.org/releases/ao/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib pulseaudio"
PKG_LONGDESC="Libao is a cross-platform audio library that allows programs to output
audio using a simple API on a wide variety of platforms."
PKG_BUILD_FLAGS="+pic"

pre_configure_target() {
export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"
}
