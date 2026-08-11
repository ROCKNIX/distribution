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
  # This builds host tools (minilua, buildvm) alongside the target library,
  # and folds a bare CFLAGS/LDFLAGS into both - see LDOPTIONS and ASOPTIONS
  # in src/Makefile. Target link flags are fatal to the host compiler:
  # ld.mold is installed cross-prefixed, so host gcc reading -fuse-ld=mold
  # fails with "collect2: cannot find 'ld'". Pass the prefixed pairs only.
  local target_ldflags="${LDFLAGS}"
  unset CFLAGS LDFLAGS
  [ "${ARCH}" = "arm" ] && BIT="-m32"
  make PREFIX="/usr" \
		CC="${CC} -fPIC" \
		TARGET_LD="${CC}" \
		TARGET_AR="${AR} rcus" \
		TARGET_STRIP=true \
		TARGET_CFLAGS="${TARGET_CFLAGS}" \
		TARGET_LDFLAGS="${target_ldflags}" \
		HOST_CC="${HOST_CC} ${BIT}" \
		HOST_CFLAGS="${HOST_CFLAGS}" \
		HOST_LDFLAGS="${HOST_LDFLAGS}" \
		XCFLAGS= \
		${JITARCH} \
		amalg
  make PREFIX=/usr DESTDIR=${INSTALL} install
  make PREFIX=/usr DESTDIR=${SYSROOT_PREFIX} install

  VER=$(grep LUAJIT_VERSION src/luajit.h | head -n1 | cut -d \" -f 2 | cut -d " " -f 2)

  ln -sf /usr/bin/luajit-${VER} ${INSTALL}/usr/bin/lua
}
