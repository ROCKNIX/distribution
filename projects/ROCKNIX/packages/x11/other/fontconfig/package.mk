# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/x11/other/fontconfig/package.mk

# keep fc-cache and friends binaries
unset -f post_makeinstall_target
