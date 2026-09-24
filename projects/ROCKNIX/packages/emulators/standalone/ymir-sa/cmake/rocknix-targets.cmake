# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

# Ymir links the vcpkg static target names; map them to the shared system libraries.
find_package(CURL CONFIG REQUIRED)
find_package(zstd CONFIG REQUIRED)

if(NOT TARGET CURL::libcurl_static)
  add_library(CURL::libcurl_static ALIAS CURL::libcurl_shared)
endif()

if(NOT TARGET zstd::libzstd_static)
  add_library(zstd::libzstd_static ALIAS zstd::libzstd_shared)
endif()
