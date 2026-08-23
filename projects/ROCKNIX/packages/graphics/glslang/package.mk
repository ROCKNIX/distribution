# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Frank Hartung (supervisedthinking (@) gmail.com)
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

. ${ROOT}/packages/graphics/vulkan/glslang/package.mk

# the SPIR-V remapper is not used by anything we ship. Appending after the
# source works because the configure hooks expand this when they run.
PKG_CMAKE_OPTS_COMMON+=" -DENABLE_SPVREMAPPER=OFF"
