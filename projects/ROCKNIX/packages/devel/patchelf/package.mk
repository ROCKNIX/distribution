# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/devel/patchelf/package.mk

# Core declares no PKG_DEPENDS_TARGET, so nothing orders the target build
# after the cross toolchain. Nothing depends on patchelf:target either -
# every reference in the tree is patchelf:host, and the target build exists
# only because patchelf ships in the image - so there is no dependency edge
# to sequence it. On a fresh tree it gets scheduled before gcc is built and
# dies with "C compiler cannot create executables". Name the toolchain the
# way every other target package does.
PKG_DEPENDS_TARGET="toolchain"
