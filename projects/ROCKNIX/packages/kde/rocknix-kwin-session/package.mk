# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rocknix-kwin-session"
PKG_VERSION=""
PKG_LICENSE="GPL"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain kwin libkscreen dbus plasma-keyboard wayland plasma-wayland-protocols"
PKG_LONGDESC="KWin compositor session for the ROCKNIX gaming frontend"
PKG_TOOLCHAIN="manual"

make_target() {
  local xml=${SYSROOT_PREFIX}/usr/share/plasma-wayland-protocols/plasma-window-management.xml
  mkdir -p ${PKG_BUILD}
  ${TOOLCHAIN}/bin/wayland-scanner client-header ${xml} ${PKG_BUILD}/plasma-window-management-client-protocol.h
  ${TOOLCHAIN}/bin/wayland-scanner private-code ${xml} ${PKG_BUILD}/plasma-window-management-protocol.c
  ${CC} ${CFLAGS} -I${PKG_BUILD} ${PKG_DIR}/sources/kwin-active-window.c ${PKG_BUILD}/plasma-window-management-protocol.c \
    ${LDFLAGS} -lwayland-client -o ${PKG_BUILD}/kwin-active-window
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_DIR}/scripts/kwin-session ${PKG_DIR}/scripts/kwin-screenshot ${INSTALL}/usr/bin
    cp ${PKG_BUILD}/kwin-active-window ${INSTALL}/usr/bin
    chmod 0755 ${INSTALL}/usr/bin/kwin-session ${INSTALL}/usr/bin/kwin-screenshot

  mkdir -p ${INSTALL}/usr/share/applications
    cp ${PKG_DIR}/applications/org.rocknix.kwin-active-window.desktop ${INSTALL}/usr/share/applications

  mkdir -p ${INSTALL}/usr/share/rocknix-kwin
    cp -r ${PKG_DIR}/config/gaming ${INSTALL}/usr/share/rocknix-kwin
    cp ${PKG_DIR}/kwin-scripts/dualscreen.js ${INSTALL}/usr/share/rocknix-kwin
}
