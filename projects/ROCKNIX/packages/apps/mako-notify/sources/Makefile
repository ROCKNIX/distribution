# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

DBUS_CFLAGS ?= $(shell pkg-config --cflags dbus-1)
DBUS_LIBS ?= $(shell pkg-config --libs dbus-1)

BINARY = mako-notify
SOURCES = mako-notify.cpp

all:
	$(CXX) $(CFLAGS) $(DBUS_CFLAGS) $(SOURCES) -o $(BINARY) $(DBUS_LIBS)
