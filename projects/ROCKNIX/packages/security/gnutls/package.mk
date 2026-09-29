# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/security/gnutls/package.mk

# GnuTLS resolves its trust store at build time, and upstream's recipe names
# none -- so it reports "GnuTLS was not configured with a system trust" and
# every certificate fails to verify, even though the image ships three copies
# of the CA bundle. Nothing noticed until something other than rclone needed
# HTTPS: rclone carries its own roots inside the Go binary.
PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_TARGET} \
                           --with-default-trust-store-file=/etc/ssl/certs/ca-certificates.crt"
