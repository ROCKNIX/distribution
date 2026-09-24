# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

find_path(Stb_INCLUDE_DIR stb_image.h PATH_SUFFIXES stb)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Stb DEFAULT_MSG Stb_INCLUDE_DIR)
