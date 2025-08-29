# SPDX-License-Identifier: GPL-2.0-or-later AND MPL-2.0

PKG_NAME="ca-certificates"
PKG_VERSION="20230311"
PKG_LICENSE="GPL-2.0+ (scripts), MPL-2.0 (data)"
PKG_SITE="https://salsa.debian.org/debian/ca-certificates"
PKG_URL="https://snapshot.debian.org/archive/debian/20230317T205011Z/pool/main/c/ca-certificates/ca-certificates_${PKG_VERSION}.tar.xz"
PKG_SHA256="83de934afa186e279d1ed08ea0d73f5cf43a6fbfb5f00874b6db3711c64576f3"

PKG_LONGDESC="PEM files of CA certificates for validating TLS connections."
PKG_TOOLCHAIN="manual"

# LibreELEC-style deps:
# - Target deps usually empty for this package.
# - Host deps: we need Python (to run the cert conversion scripts) and OpenSSL for c_rehash.
PKG_DEPENDS_TARGET="toolchain"
PKG_DEPENDS_HOST="Python3:host openssl:host"

# If you added the “cryptography optional” patch, place it under:
# projects/ROCKNIX/packages/web/ca-certificates/patches/*.patch

make_target() {
  make -C "${PKG_BUILD}" clean all
}

makeinstall_target() {
  # 1) Ensure dirs
  mkdir -p \
    "${INSTALL}/usr/share/ca-certificates/mozilla" \
    "${INSTALL}/etc/ssl/certs"

  # 2) Copy all generated Mozilla CRTs
  # (certdata2pem.py dumped them into ${PKG_BUILD}/mozilla/*.crt)
  cp -a "${PKG_BUILD}/mozilla/"*.crt \
        "${INSTALL}/usr/share/ca-certificates/mozilla/"

  # 3) Rebuild bundle and hashed links
  rm -f "${INSTALL}/etc/ssl/certs/"*
  (
    cd "${INSTALL}" || exit 1
    # symlink each CRT into /etc/ssl/certs/*.pem and build a single bundle
    find usr/share/ca-certificates -name '*.crt' | LC_COLLATE=C sort | while read -r i; do
      ln -sf "../../../$i" "etc/ssl/certs/$(basename "${i%.crt}").pem"
      cat "$i"
    done > "${BUILD}/ca-certificates.crt"
  )

  # 4) Hash symlinks (needs openssl:host)
  "${TOOLCHAIN}/bin/c_rehash" "${INSTALL}/etc/ssl/certs"

  # 5) Install the bundle
  install -Dm0644 "${BUILD}/ca-certificates.crt" \
    "${INSTALL}/etc/ssl/certs/ca-certificates.crt"

  # 6) (Optional) Drop Debian’s helper we don’t use
  rm -f "${INSTALL}/usr/sbin/update-ca-certificates" 2>/dev/null || true
}

post_makeinstall_target() {
  # Optional: stage the bundle too
  if [ -n "${STAGING}" ]; then
    mkdir -p "${STAGING}/etc/ssl/certs"
    cp -a "${INSTALL}/etc/ssl/certs/ca-certificates.crt" "${STAGING}/etc/ssl/certs/" 2>/dev/null || true
  fi
}
