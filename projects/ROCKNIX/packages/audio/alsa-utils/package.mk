# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="alsa-utils"
PKG_VERSION="1.2.16"
PKG_SHA256="092399d5e8749a1d5e188e393157521cec4b75693b60ebb79bbce728cff2232c"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://www.alsa-project.org/"
PKG_URL="https://www.alsa-project.org/files/pub/utils/alsa-utils-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain alsa-lib ncurses systemd alsa-ucm-conf"
PKG_LONGDESC="This package includes the utilities for ALSA, like alsamixer, aplay, arecord, alsactl, iecset and speaker-test."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--disable-alsaconf \
                           --disable-alsaloop \
                           --enable-alsatest \
                           --disable-bat \
                           --disable-dependency-tracking \
                           --disable-nls \
                           --disable-rst2man \
                           --disable-xmlto"

post_makeinstall_target() {
  rm -rf ${INSTALL}/lib ${INSTALL}/var
  rm -rf ${INSTALL}/usr/share/alsa/speaker-test
  rm -rf ${INSTALL}/usr/share/sounds
  rm -rf ${INSTALL}/usr/lib/systemd/system
}
