# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/security/openssl/package.mk

post_makeinstall_target() {
  rm -rf ${INSTALL}/etc/ssl/misc
  rm -rf ${INSTALL}/usr/bin/c_rehash

  debug_strip ${INSTALL}/usr/bin/openssl

  # cert from https://curl.haxx.se/docs/caextract.html
  mkdir -p ${INSTALL}/etc/ssl
    cp ${PKG_DIR}/cert/cacert.pem ${INSTALL}/etc/ssl/cacert.pem.system

  # give user the chance to include their own CA
  mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_DIR}/scripts/openssl-config ${INSTALL}/usr/bin
    ln -sf /run/rocknix/cacert.pem ${INSTALL}/etc/ssl/cacert.pem
    ln -sf /run/rocknix/cacert.pem ${INSTALL}/etc/ssl/cert.pem

  # backwards compatibility
  mkdir -p ${INSTALL}/etc/pki/tls
    ln -sf /run/rocknix/cacert.pem ${INSTALL}/etc/pki/tls/cacert.pem
  mkdir -p ${INSTALL}/etc/pki/tls/certs
    ln -sf /run/rocknix/cacert.pem ${INSTALL}/etc/pki/tls/certs/ca-bundle.crt
  mkdir -p ${INSTALL}/usr/lib/ssl
    ln -sf /run/rocknix/cacert.pem ${INSTALL}/usr/lib/ssl/cert.pem
}

post_install() {
  enable_service openssl-config.service
}
