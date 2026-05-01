# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)
PKG_NAME="gcc"
PKG_VERSION="15.2.0"
PKG_SHA256="438fd996826b0c82485a29da03a72d71d6e3541a83ec702df4271f6fe025d24e"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://gcc.gnu.org/"
PKG_URL="https://ftpmirror.gnu.org/gcc/${PKG_NAME}-${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_BOOTSTRAP="ccache:host autoconf:host binutils:host gmp:host mpfr:host mpc:host zstd:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_DEPENDS_HOST="ccache:host autoconf:host binutils:host gmp:host mpfr:host mpc:host zstd:host glibc libxcrypt"
PKG_DEPENDS_INIT="toolchain"
PKG_LONGDESC="This package contains the GNU Compiler Collection."

if [ "${MOLD_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_HOST+=" mold:host"
fi

case ${TARGET_ARCH} in
  arm|aarch64)
    OPTS_LIBATOMIC="--enable-libatomic"
    ;;
  *)
    OPTS_LIBATOMIC="--disable-libatomic"
    ;;
esac

GCC_COMMON_CONFIGURE_OPTS="--target=${TARGET_NAME} \
                           --with-sysroot=${SYSROOT_PREFIX} \
                           --with-gmp=${TOOLCHAIN} \
                           --with-mpfr=${TOOLCHAIN} \
                           --with-mpc=${TOOLCHAIN} \
                           --with-zstd=${TOOLCHAIN} \
                           --with-gnu-as \
                           --with-gnu-ld \
                           --enable-plugin \
                           --enable-lto \
                           --enable-gold \
                           --enable-ld=default \
                           --with-linker-hash-style=gnu \
                           --disable-multilib \
                           --disable-nls \
                           --enable-checking=release \
                           --without-ppl \
                           --without-cloog \
                           --disable-libada \
                           --disable-libmudflap \
                           --disable-libitm \
                           --disable-libquadmath \
                           --enable-libgomp \
                           --disable-libmpx \
                           --disable-libssp \
                           --disable-static \
                           --enable-shared \
                           --disable-werror \
                           --enable-__cxa_atexit"

PKG_CONFIGURE_OPTS_BOOTSTRAP="${GCC_COMMON_CONFIGURE_OPTS} \
                              --enable-cloog-backend=isl \
                              --disable-decimal-float \
                              --disable-gcov \
                              --enable-languages=c \
                              --disable-libatomic \
                              --disable-libgomp \
                              --disable-libsanitizer \
                              --disable-shared \
                              --disable-threads \
                              --without-headers \
                              --with-newlib \
                              ${TARGET_ARCH_GCC_OPTS}"

PKG_CONFIGURE_OPTS_HOST="${GCC_COMMON_CONFIGURE_OPTS} \
                         --enable-languages=c,c++ \
                         ${OPTS_LIBATOMIC} \
                         --enable-decimal-float \
                         --enable-tls \
                         --enable-shared \
                         --disable-static \
                         --enable-long-long \
                         --enable-threads=posix \
                         --disable-libstdcxx-pch \
                         --enable-libstdcxx-time \
                         --enable-clocale=gnu \
                         ${TARGET_ARCH_GCC_OPTS}"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
    cp -P ${PKG_BUILD}/.${HOST_NAME}/${TARGET_NAME}/libgcc/libgcc_s.so* ${INSTALL}/usr/lib
    cp -P ${PKG_BUILD}/.${HOST_NAME}/${TARGET_NAME}/libstdc++-v3/src/.libs/libstdc++.so* ${INSTALL}/usr/lib
    cp -P ${PKG_BUILD}/.${HOST_NAME}/${TARGET_NAME}/libgomp/.libs/*.so* ${INSTALL}/usr/lib
    cp -P ${PKG_BUILD}/.${HOST_NAME}/${TARGET_NAME}/libsanitizer/asan/.libs/*.so* ${INSTALL}/usr/lib
    cp -P ${PKG_BUILD}/.${HOST_NAME}/${TARGET_NAME}/libsanitizer/ubsan/.libs/*.so* ${INSTALL}/usr/lib
    if [ "${OPTS_LIBATOMIC}" = "--enable-libatomic" ]; then
      cp -P ${PKG_BUILD}/.${HOST_NAME}/${TARGET_NAME}/libatomic/.libs/libatomic.so* ${INSTALL}/usr/lib
    fi
}
