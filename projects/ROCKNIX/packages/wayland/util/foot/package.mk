# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

# This shadow exists only for the checksum override below. It must keep
# scripts/ and config/, because PKG_DIR resolves here rather than merging
# with core, and the inherited install step copies from PKG_DIR; both are
# cosmetic duplicates of core's. The whole directory goes when the
# override does.
. ${ROOT}/packages/wayland/util/foot/package.mk

# See the fcft shadow: codeberg regenerated its cached archive for this
# tag, so LibreELEC's recorded checksum no longer matches upstream.
# Content verified as upstream 1.27.0.
PKG_SHA256="f5917cad2d7b723b99873e53d78fd10ea202923d189aed5086591fc53b70b7e3"
