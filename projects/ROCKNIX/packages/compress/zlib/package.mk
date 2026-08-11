# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

. ${ROOT}/packages/compress/zlib/package.mk

# zlib.net rate limits, and a CI matrix fetching it from twenty jobs at
# once gets a short error page instead of the tarball: the checksum then
# fails and there is no mirror copy to fall back to. GitHub serves the
# identical release tarball - same PKG_SHA256 - from a CDN.
PKG_URL="https://github.com/madler/zlib/releases/download/v${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
