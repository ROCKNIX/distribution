# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/devel/ncurses/package.mk

PKG_URL="https://ftpmirror.gnu.org/ncurses/ncurses-${PKG_VERSION}.tar.gz"

PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_TARGET/--without-shared/--with-shared}"
PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_TARGET/--without-termlib/--with-termlib}"
PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_TARGET/--disable-sigwinch/}"
PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_TARGET/--disable-tcap-names/--enable-tcap-names}"
PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_TARGET/--enable-hashmap/--disable-hashmap}"
PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_TARGET/--disable-home-terminfo/--enable-home-terminfo}"
PKG_CONFIGURE_OPTS_TARGET+=" --enable-lib-suffixes"
PKG_CONFIGURE_OPTS_HOST+=" --without-tests"

eval "core_$(declare -f pre_configure_target)"
pre_configure_target() {
  core_pre_configure_target
  CFLAGS="${CFLAGS} -std=gnu17"
}

eval "core_$(declare -f post_makeinstall_target)"
post_makeinstall_target() {
  core_post_makeinstall_target
  ln -sf libtinfow.a ${SYSROOT_PREFIX}/usr/lib/libtinfo.a
  ln -sf tinfow.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig/tinfo.pc
  cd ${INSTALL}/usr/lib
  for LIB in *w*.so*
  do
    NOWLIB=$(echo ${LIB} | sed "s#w##g")
    ln -sf ${LIB} ${INSTALL}/usr/lib/${NOWLIB}
  done
  cd -
}
