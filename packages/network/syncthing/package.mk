# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="syncthing"
PKG_VERSION="1.27.1"
PKG_LICENSE="MPLv2"
PKG_SITE="https://syncthing.net/"
PKG_URL="https://github.com/syncthing/syncthing/releases/download/v${PKG_VERSION}/syncthing-source-v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain go:host"
PKG_LONGDESC="Syncthing: open source continuous file synchronization"
PKG_TOOLCHAIN="manual"

configure_target() {
  go_configure
  export LDFLAGS="-w -linkmode external -extldflags -Wl,--unresolved-symbols=ignore-in-shared-libs -extld ${CC} \
                  -X github.com/syncthing/syncthing/lib/build.Version=v${PKG_VERSION}"
}

make_target() {
  HOME=${ROOT} GOCACHE=${ROOT}/.cache/go-build \
       ${GOLANG} build -a -ldflags "${LDFLAGS}" -o bin/syncthing -v ./cmd/syncthing
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp bin/syncthing ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/sources/start_syncthing.sh ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/*
}
