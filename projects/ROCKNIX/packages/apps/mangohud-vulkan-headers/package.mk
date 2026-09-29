# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mangohud-vulkan-headers"
# The release mangohud's own subprojects/vulkan-headers.wrap names (source_url,
# source_filename and source_hash below are the wrap's, byte for byte), carried
# as a source so the build never fetches it: mangohud's meson.build calls
# subproject('vulkan-headers') unconditionally, and scripts/build refuses meson's
# own download (--wrap-mode=nodownload, the rule a build fetches no dependency
# of its own). mangohud's recipe copies this tarball into meson's
# subprojects/packagecache before it configures; meson unpacks it from there
# and applies the wrap's packagefiles. Source only: nothing here is built or
# installed on its own.
# freshness: pinned -- follows subprojects/vulkan-headers.wrap at mangohud's pinned commit (bump both together)
PKG_VERSION="1.4.346"
PKG_SHA256="5bb77f5d7b460e255a9e51affc00d64354986b55cf577d8eab28529cad01fc80"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://github.com/KhronosGroup/Vulkan-Headers"
PKG_URL="${PKG_SITE}/archive/v${PKG_VERSION}.tar.gz"
PKG_SOURCE_NAME="vulkan-headers-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="the Vulkan headers at the release mangohud's meson wrap pins, as a source for mangohud's subproject cache."
PKG_TOOLCHAIN="manual"
