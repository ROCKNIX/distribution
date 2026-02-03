# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libiio"
PKG_VERSION="v0.26"
PKG_LICENSE="LGPL-2.1+"
PKG_SITE="https://github.com/analogdevicesinc/libiio"
PKG_URL="${PKG_SITE}/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libxml2 libusb libaio Python3 flex:host bison:host"
PKG_LONGDESC="A cross platform library for interfacing with local and remote Linux IIO devices"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release \
                         -DWITH_LOCAL_BACKEND=ON \
                         -DWITH_NETWORK_BACKEND=OFF \
                         -DWITH_XML_BACKEND=OFF \
                         -DWITH_USB_BACKEND=OFF \
                         -DENABLE_EXAMPLES=OFF \
                         -DWITH_DOC=OFF \
                         -DWITH_TESTS=OFF \
                         -DNO_THREADS=OFF \
                         -DWITH_IIOD=OFF \
                         -DWITH_IIOD_USBD=OFF \
                         -DWITH_AIO=OFF \
                         -DPYTHON_BINDINGS=ON \
                         -DPYTHON_EXECUTABLE=python3"
