# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2023-present NeoTheFox (https://github.com/NeoTheFox)

PKG_NAME="simple-http-server"
PKG_VERSION="0.6.13"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/TheWaWaR/simple-http-server"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Simple http server in Rust"
PKG_TOOLCHAIN="manual"

case ${ARCH} in
  x86_64)
    PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/x86_64-unknown-linux-musl-simple-http-server"
    ;;
  arm)
    PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/armv7-unknown-linux-musleabihf-simple-http-server"
    ;;
  aarch64)
    PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/aarch64-unknown-linux-musl-simple-http-server"
    ;;
esac

unpack() {
  mkdir -p ${PKG_BUILD}
  cp ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.${ARCH}*${PKG_NAME} ${PKG_BUILD}/simple-http-server
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  install -Dm755 ${PKG_BUILD}/simple-http-server ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/lib/systemd/system
  install -Dm644 ${PKG_DIR}/system.d/simple-http-server.service ${INSTALL}/usr/lib/systemd/system
}
