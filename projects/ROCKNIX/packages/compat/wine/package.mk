# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="wine"
PKG_VERSION="11.0"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/Kron4ek/Wine-Builds"
case ${TARGET_ARCH} in
  x86_64)
    # WoW64 runs 32-bit Windows programs without 32-bit host libraries,
    # which x86_64 devices do not ship.
    PKG_SHA256="39574efa1132c3ca0d5c77dd2eddbe4a49cca0d6cc2c290ff4924493a1c40314"
    PKG_URL="${PKG_SITE}/releases/download/${PKG_VERSION}/wine-${PKG_VERSION}-amd64-wow64.tar.xz"
    ;;
  *)
    PKG_SHA256="632f2c8e9150841c26d277000e76b82c425cd4564bfb050780705b9d37b2567f"
    PKG_URL="${PKG_SITE}/releases/download/${PKG_VERSION}/wine-${PKG_VERSION}-amd64.tar.xz"
    ;;
esac

PKG_DEPENDS_TARGET="toolchain libXcomposite libXdmcp cups"
PKG_LONGDESC="Wine is a compatibility layer capable of running Windows applications"
PKG_TOOLCHAIN="manual"
PKG_WINE_TRICKS="https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"

unpack() {
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -rf ${PKG_BUILD}/bin/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/lib
    cp -rf ${PKG_BUILD}/lib/* ${INSTALL}/usr/lib

  mkdir -p ${INSTALL}/usr/share
    cp -rf ${PKG_BUILD}/share/* ${INSTALL}/usr/share

  curl -Lo ${INSTALL}/usr/bin/winetricks ${PKG_WINE_TRICKS}

  chmod +x ${INSTALL}/usr/bin/*
}
