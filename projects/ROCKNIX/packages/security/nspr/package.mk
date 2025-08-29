# SPDX-License-Identifier: MPL-2.0
# Netscape Portable Runtime (NSPR)

PKG_NAME="nspr"
PKG_VERSION="4.36"
PKG_LICENSE="MPL-2.0"
PKG_SITE="https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSPR"
PKG_URL="https://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v${PKG_VERSION}/src/nspr-${PKG_VERSION}.tar.gz"
PKG_SHA256="55dec317f1401cd2e5dba844d340b930ab7547f818179a4002bce62e6f1c6895"

PKG_LONGDESC="NSPR provides a platform-neutral API for low-level system functionality."
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="manual"   # Use NSPR's shipped ./configure (no autoreconf)

# Toggle 64-bit for common arches
case "${TARGET_ARCH}" in
  aarch64|x86_64|ppc64|ppc64le|mips64*|riscv64) _NSPR_64="--enable-64bit" ;;
  *) _NSPR_64="" ;;
esac

# Extra CFLAGS for musl toolchains (mirrors Alpine/Buildroot defines)
_NSRT_MUSL_CFLAGS=""
[ "${TARGET_LIBC}" = "musl" ] && _NSRT_MUSL_CFLAGS="${_NSRT_MUSL_CFLAGS} \
  -D_PR_POLL_AVAILABLE -D_PR_HAVE_OFF64_T -D_PR_INET6 -D_PR_HAVE_INET_NTOP \
  -D_PR_HAVE_GETHOSTBYNAME2 -D_PR_HAVE_GETADDRINFO -D_PR_INET6_PROBE"

configure_target() {
  local SRC="${PKG_BUILD}/nspr"
  cd "${SRC}"

  # Ensure host (build) helpers are compiled with native CC, not target flags
  env \
    CC="${CC}" CXX="${CXX}" AR="${AR}" RANLIB="${RANLIB}" LD="${LD}" \
    CFLAGS="${CFLAGS} ${_NSRT_MUSL_CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    CC_FOR_BUILD="${HOST_CC}" CFLAGS_FOR_BUILD="-O2 -pipe" \
    HOST_CC="${HOST_CC}" HOST_CFLAGS="-O2 -pipe" HOST_LDFLAGS="-lc" \
    ./configure \
      --host="${TARGET_NAME}" \
      --prefix="/usr" \
      --with-mozilla \
      --with-pthreads \
      ${_NSPR_64}
}

make_target() {
  local SRC="${PKG_BUILD}/nspr"
  make -C "${SRC}" ${MAKEFLAGS} \
    CC_FOR_BUILD="${HOST_CC}" CFLAGS_FOR_BUILD="-O2 -pipe" \
    HOST_CC="${HOST_CC}" HOST_CFLAGS="-O2 -pipe" HOST_LDFLAGS="-lc"
}

makeinstall_target() {
  local SRC="${PKG_BUILD}/nspr"

  # Install into target rootfs
  make -C "${SRC}" DESTDIR="${INSTALL}" install \
    CC_FOR_BUILD="${HOST_CC}" CFLAGS_FOR_BUILD="-O2 -pipe" \
    HOST_CC="${HOST_CC}" HOST_CFLAGS="-O2 -pipe" HOST_LDFLAGS="-lc"

  # Also install into sysroot (staging) so dependents (e.g., NSS) can link
  make -C "${SRC}" DESTDIR="${SYSROOT_PREFIX}" install \
    CC_FOR_BUILD="${HOST_CC}" CFLAGS_FOR_BUILD="-O2 -pipe" \
    HOST_CC="${HOST_CC}" HOST_CFLAGS="-O2 -pipe" HOST_LDFLAGS="-lc"
}
