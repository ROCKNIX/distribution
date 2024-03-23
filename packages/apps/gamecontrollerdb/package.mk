# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="gamecontrollerdb"
PKG_VERSION="e1f095abb7cb6f201b40bc25b62fa4bd92edbbc0"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_SITE="https://github.com/gabomdq/SDL_GameControllerDB"
PKG_URL="${PKG_SITE}.git"
PKG_SECTION="tools"
PKG_SHORTDESC="SDL Game Controller DB"
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/SDL-GameControllerDB
  if [ -f "${PKG_DIR}/config/gamecontrollerdb.txt" ]
  then
    cat ${PKG_DIR}/config/gamecontrollerdb.txt >${INSTALL}/usr/config/SDL-GameControllerDB/gamecontrollerdb.txt
  fi
  cat ${PKG_BUILD}/gamecontrollerdb.txt >>${INSTALL}/usr/config/SDL-GameControllerDB/gamecontrollerdb.txt
}
