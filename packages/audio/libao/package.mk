# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="libao"
PKG_VERSION="1.2.0"
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
