# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/addons/addon-depends/chrome-depends/harfbuzz-icu/package.mk

# The chrome-depends recipe builds this for an addon, so it carries
# PKG_BUILD_FLAGS="-sysroot" and installs nowhere anything can link against.
# WebKit calls hb_icu_script_to_script() directly, so it needs the real
# library in the sysroot -- the build otherwise fails at configure with
# "The following HarfBuzz libraries were not found: ICU", which reads like
# harfbuzz is missing when in fact it was built and then withheld.
unset PKG_BUILD_FLAGS
