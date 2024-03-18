# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="soundfont-generaluser"
PKG_VERSION="8fe2798"
PKG_LICENSE="OSS"
PKG_SITE="http://www.schristiancollins.com/generaluser.php"
PKG_URL="https://github.com/ROCKNIX/generaluser-gs/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="GeneralUser GS is a GM and GS compatible SoundFont bank for composing, playing MIDI files, and retro gaming."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/soundfonts
  cp ${PKG_BUILD}/GeneralUser*.sf2 ${INSTALL}/usr/share/soundfonts/GeneralUser.sf2
}
