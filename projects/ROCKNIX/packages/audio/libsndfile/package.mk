# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/audio/libsndfile/package.mk

PKG_CMAKE_OPTS_TARGET+=" -DBUILD_SHARED_LIBS=ON \
                         -DCMAKE_POLICY_VERSION_MINIMUM=3.5"
