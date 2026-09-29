# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mangohud-vulkan-utility-libraries"
# The release mangohud's own subprojects/vulkan-utility-libraries.wrap names (source_url,
# source_filename and source_hash below are the wrap's, byte for byte), carried
# as a source so the build never fetches it: mangohud's meson.build calls
# subproject('vulkan-utility-libraries') unconditionally, and scripts/build refuses meson's
# own download (--wrap-mode=nodownload, the rule a build fetches no dependency
# of its own). mangohud's recipe copies this tarball into meson's
# subprojects/packagecache before it configures; meson unpacks it from there
# and applies the wrap's packagefiles. Source only: nothing here is built or
# installed on its own.
# freshness: pinned -- follows subprojects/vulkan-utility-libraries.wrap at mangohud's pinned commit (bump both together)
PKG_VERSION="1.4.346"
PKG_SHA256="372eb525103ecb4e3a04d030b2a9778ebc67853bbdc82ce6747de3757d432ad9"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://github.com/KhronosGroup/Vulkan-Utility-Libraries"
PKG_URL="${PKG_SITE}/archive/v${PKG_VERSION}.tar.gz"
PKG_SOURCE_NAME="vulkan-utility-libraries-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="the Vulkan utility libraries at the release mangohud's meson wrap pins, as a source for mangohud's subproject cache."
PKG_TOOLCHAIN="manual"
