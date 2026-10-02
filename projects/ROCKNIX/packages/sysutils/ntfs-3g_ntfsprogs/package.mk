# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/addons/addon-depends/ntfs-3g_ntfsprogs/package.mk

# tuxera.com refuses GitHub's CI runners, buildroot's mirror serves the same tarball
PKG_URL="https://sources.buildroot.net/ntfs-3g/${PKG_NAME}-${PKG_VERSION}.tgz"
