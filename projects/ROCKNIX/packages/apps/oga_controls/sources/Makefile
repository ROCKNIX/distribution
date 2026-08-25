# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

CFLAGS += -fpermissive

EVDEV_CFLAGS ?= $(shell pkg-config --cflags libevdev)
EVDEV_LIBS ?= $(shell pkg-config --libs libevdev)

BINARY = oga_controls
LIBRARIES = -lSDL2
SOURCES = main.c

all:
	$(CXX) $(CFLAGS) $(EVDEV_CFLAGS) $(SOURCES) -o $(BINARY) $(EVDEV_LIBS)
