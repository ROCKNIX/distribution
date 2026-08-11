# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

# Shadowed for the ROCKNIX foot.sh launcher in scripts/; PKG_DIR resolves
# here, so the inherited install step picks up our script and config
. ${ROOT}/packages/wayland/util/foot/package.mk

# See the fcft shadow: codeberg regenerated its cached archive for this
# tag, so LibreELEC's recorded checksum no longer matches upstream.
# Content verified as upstream 1.27.0.
PKG_SHA256="f5917cad2d7b723b99873e53d78fd10ea202923d189aed5086591fc53b70b7e3"

pre_configure_target() {
  export TARGET_CFLAGS="${TARGET_CFLAGS} -Wno-error=switch"
}
