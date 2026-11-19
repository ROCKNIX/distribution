# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="portaudio"
PKG_VERSION="64d1bf913433d7a2835526b80a93487d5038cb8e"
PKG_SHA256="c33e48217a844cca3b66ab88571b90beefb8fcb6967177951d4dc283587bf834"
PKG_LICENSE="ISC"
PKG_SITE="https://portaudio.com"
PKG_URL="https://github.com/zhang-ray/portaudio/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib"
PKG_LONGDESC="PortAudio is a free, cross-platform, open-source, audio I/O library."

PKG_CMAKE_OPTS_TARGET="-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
