# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="hidapi"
PKG_VERSION="7011fa98af2dde00c298105735e470de800288c7"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libusb/hidapi"
PKG_URL="https://github.com/libusb/hidapi/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd libusb"
PKG_LONGDESC="Simple library for communicating with USB and Bluetooth HID devices."
PKG_TOOLCHAIN="cmake"

