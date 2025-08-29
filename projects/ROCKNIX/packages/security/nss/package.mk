# SPDX-License-Identifier: MPL-2.0
# Mozilla Network Security Services (NSS)

PKG_NAME="nss"
PKG_VERSION="3.106"
PKG_LICENSE="MPL-2.0"
PKG_SITE="https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS"
PKG_URL="https://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_$(echo ${PKG_VERSION} | tr . _)_RTM/src/nss-${PKG_VERSION}.tar.gz"
PKG_SHA256="026b744e1e0784b890c3846ac9506472a92138c1f4d41dec581949574c585c38"

PKG_LONGDESC="NSS provides libraries for SSL/TLS, PKCS*, S/MIME and X.509."
PKG_DEPENDS_TARGET="toolchain nspr ca-certificates sqlite zlib"
PKG_TOOLCHAIN="manual"   # coreconf (non-autotools/meson)

# Map TARGET_ARCH -> OS_TEST
case "${TARGET_ARCH}" in
  aarch64)  _NSS_OS_TEST="aarch64" ;;
  arm)      _NSS_OS_TEST="arm" ;;
  x86_64)   _NSS_OS_TEST="x86_64" ;;
  i386)     _NSS_OS_TEST="i686" ;;
  mips64*)  _NSS_OS_TEST="mips64" ;;
  mips*)    _NSS_OS_TEST="mips" ;;
  ppc64le)  _NSS_OS_TEST="ppc64le" ;;
  ppc64)    _NSS_OS_TEST="ppc64" ;;
  ppc)      _NSS_OS_TEST="ppc" ;;
  riscv64)  _NSS_OS_TEST="riscv64" ;;
  *)        _NSS_OS_TEST="${TARGET_ARCH}" ;;
esac

# 64-bit
_NSS_USE_64=""
case "${TARGET_ARCH}" in
  aarch64|x86_64|ppc64|ppc64le|mips64*|riscv64) _NSS_USE_64="USE_64=1" ;;
esac

# Common make vars
_nss_make_vars() {
  cat <<-EOF
MOZILLA_CLIENT=1
NS_USE_GCC=1
NSS_DISABLE_GTESTS=1
NSS_USE_SYSTEM_SQLITE=1
NSS_ENABLE_WERROR=0
NATIVE_CC="${HOST_CC}"
OS_ARCH=Linux
OS_RELEASE=2.6
OS_TEST=${_NSS_OS_TEST}
NSPR_INCLUDE_DIR=${SYSROOT_PREFIX}/usr/include/nspr
NSPR_LIB_DIR=${SYSROOT_PREFIX}/usr/lib
${_NSS_USE_64}
EOF
}

pre_configure_target() {
  # Append our flags to the right file inside the tree
  local LINUX_MK="${PKG_BUILD}/nss/coreconf/Linux.mk"
  echo "OS_CFLAGS += ${CFLAGS}"  >> "${LINUX_MK}"
  echo "LDFLAGS   += ${LDFLAGS}" >> "${LINUX_MK}"

  # Optional: if arm without NEON
  if [ "${TARGET_ARCH}" = "arm" ] && ! echo "${TARGET_CPU}" | grep -qi neon; then
    echo "NSS_DISABLE_ARM32_NEON=1" >> "${LINUX_MK}"
  fi
}

make_target() {
  local DIST="${PKG_BUILD}/dist"

  # 1) coreconf bootstrap
  make -C "${PKG_BUILD}/nss" \
    $(_nss_make_vars) \
    coreconf \
    SOURCE_MD_DIR="${PKG_BUILD}/dist" \
    DIST="${DIST}" \
    CHECKLOC=

  # 2) dbm + all libs/tools
  make -C "${PKG_BUILD}/nss" \
    $(_nss_make_vars) \
    lib/dbm all \
    SOURCE_MD_DIR="${PKG_BUILD}/dist" \
    DIST="${DIST}" \
    CHECKLOC= \
    NATIVE_FLAGS="-O2 -DLINUX" \
    NATIVE_LDFLAGS=
}

makeinstall_target() {
  local DIST="${PKG_BUILD}/dist"

  mkdir -p "${INSTALL}/usr/lib" "${INSTALL}/usr/include/nss" "${INSTALL}/usr/bin" "${INSTALL}/usr/lib/pkgconfig"

  # IMPORTANT: copy real files (follow symlinks) so runtime doesn't point into build tree
  cp -Lv "${DIST}/lib/"*.so "${INSTALL}/usr/lib/" 2>/dev/null || true
  cp -Lv "${DIST}/lib/"*.a  "${INSTALL}/usr/lib/" 2>/dev/null || true

  # Headers
  cp -a "${DIST}/public/nss/"* "${INSTALL}/usr/include/nss/"

  # Tools
  [ -x "${DIST}/bin/certutil" ] && install -m0755 "${DIST}/bin/certutil" "${INSTALL}/usr/bin/"

  # pkg-config
  cat > "${INSTALL}/usr/lib/pkgconfig/nss.pc" <<-EOF
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include/nss

Name: nss
Description: Network Security Services
Version: ${PKG_VERSION}
Requires: nspr
Libs: -L\${libdir} -lnss3 -lnssutil3 -lsmime3 -lssl3 -lnspr4 -lplc4 -lplds4
Cflags: -I\${includedir}
EOF

  # Stage for dependents
  if [ -n "${STAGING}" ]; then
    mkdir -p "${STAGING}/usr/lib" "${STAGING}/usr/include/nss" "${STAGING}/usr/lib/pkgconfig"
    cp -Lv "${INSTALL}/usr/lib/"*.so "${STAGING}/usr/lib/" 2>/dev/null || true
    cp -Lv "${INSTALL}/usr/lib/"*.a  "${STAGING}/usr/lib/" 2>/dev/null || true
    cp -a  "${INSTALL}/usr/include/nss/"* "${STAGING}/usr/include/nss/"
    cp -a  "${INSTALL}/usr/lib/pkgconfig/nss.pc" "${STAGING}/usr/lib/pkgconfig/"
  fi
}
