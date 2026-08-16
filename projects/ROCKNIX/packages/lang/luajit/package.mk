# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019 Trond Haugland (github.com/escalade)

PKG_NAME="luajit"
PKG_VERSION="1edc3e52b67eaf6ce5f809be8e17d6862594b8bc"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/LuaJIT/LuaJIT"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain luajit:host"
PKG_LONGDESC="LuaJIT is a Just-In-Time Compiler (JIT) for the Lua programming language. "
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="+speed"

post_patch() {
  mkdir -p ${PKG_BUILD}/.${TARGET_NAME} && cp -r ${PKG_BUILD}/* ${PKG_BUILD}/.${TARGET_NAME}
  mkdir -p ${PKG_BUILD}/.${HOST_NAME} && cp -r ${PKG_BUILD}/* ${PKG_BUILD}/.${HOST_NAME}
}


pre_make_host() {
  unset TARGET_CFLAGS
}

makeinstall_host() {
  cd .${HOST_NAME}
  make amalg
  make PREFIX=/ DESTDIR=${TOOLCHAIN} install
  VER=$(grep LUAJIT_VERSION src/luajit.h | head -n1 | cut -d \" -f 2 | cut -d " " -f 2)
  ln -sf luajit-${VER} ${TOOLCHAIN}/bin/luajit
}

makeinstall_target() {
  cd .${TARGET_NAME}
  unset CFLAGS
  [ "${ARCH}" = "arm" ] && BIT="-m32"
  make PREFIX="/usr" \
		CC="${CC} -fPIC" \
		TARGET_LD="${CC}" \
		TARGET_AR="${AR} rcus" \
		TARGET_STRIP=true \
		TARGET_CFLAGS="${TARGET_CFLAGS}" \
		TARGET_LDFLAGS="${LDFLAGS}" \
		HOST_CC="${HOST_CC} ${BIT}" \
		HOST_CFLAGS="${CFLAGS}" \
		HOST_LDFLAGS="${LDFLAGS}" \
		XCFLAGS= \
		${JITARCH} \
		amalg
  make PREFIX=/usr DESTDIR=${INSTALL} install
  make PREFIX=/usr DESTDIR=${SYSROOT_PREFIX} install

  VER=$(grep LUAJIT_VERSION src/luajit.h | head -n1 | cut -d \" -f 2 | cut -d " " -f 2)

  ln -sf /usr/bin/luajit-${VER} ${INSTALL}/usr/bin/lua
}
