# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/lang/nasm/package.mk

# Core scopes nasm to x86_64 targets, and scripts/build silently skips any
# package whose PKG_ARCH excludes the target arch - so on aarch64 devices
# nasm:host never reaches the toolchain, and libvpx:host, which assembles
# x86_64 host code on every target arch, dies at configure with
# "nasm: not found". The old shadow carried no PKG_ARCH at all; that absence
# was operative, and deleting it as cruft broke every emu-standalone leg.
PKG_ARCH="any"
