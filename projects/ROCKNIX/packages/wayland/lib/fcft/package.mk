# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

. ${ROOT}/packages/wayland/lib/fcft/package.mk

# Codeberg regenerated its cached archive for this tag, so the checksum
# LibreELEC recorded no longer matches what upstream serves; LE builds
# still pass because their own mirror holds the original bytes and ours
# does not. Content verified as upstream 3.3.3. Drop this once the
# tarball is on the ROCKNIX sources mirror.
PKG_SHA256="b0c0f4a599f43723736c8565b8b84337c4195077f07f1bb8bb3252bb13a2306a"

pre_configure_target() {
  export TARGET_CFLAGS="${TARGET_CFLAGS} -Wno-error=maybe-uninitialized"
}
