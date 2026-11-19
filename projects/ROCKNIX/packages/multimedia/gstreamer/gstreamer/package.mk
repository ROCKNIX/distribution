# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/multimedia/gstreamer/gstreamer/package.mk

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/share
}
