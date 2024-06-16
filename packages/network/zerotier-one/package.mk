# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present kkoshelev (https://github.com/kkoshelev)
# Copyright (C) 2022-present fewtarius (https://github.com/fewtarius)
# Copyright (C) 2023-present NeoTheFox (https://github.com/NeoTheFox)

PKG_NAME="zerotier-one"
PKG_VERSION="1.14.0"
PKG_SITE="https://www.zerotier.com"
PKG_URL="https://github.com/zerotier/ZeroTierOne/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain nlohmann-json"
PKG_LONGDESC="A Smart Ethernet Switch for Earth"
PKG_TOOLCHAIN="manual"


pre_unpack() {
    mkdir -p ${PKG_BUILD}
    tar --strip-components=1 -xf $SOURCES/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz -C ${PKG_BUILD} ZeroTierOne-${PKG_VERSION}
}


make_target() {
    cd ${PKG_BUILD}
    make -f make-linux.mk ZT_SSO_SUPPORTED=0 one
}

makeinstall_target() {
    make DESTDIR=${INSTALL} install
    rm -rf ${INSTALL}/usr/share/man/

    install -Dm755 ${PKG_DIR}/scripts/zerotier-join.sh ${INSTALL}/usr/sbin/
    mkdir -p ${INSTALL}/usr/lib/systemd/system
    install -Dm644 ${PKG_DIR}/system.d/zerotier-one.service ${INSTALL}/usr/lib/systemd/system/
}

