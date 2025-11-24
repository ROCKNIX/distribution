# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

SRC_DIR = $(CURDIR)/jammy/arm64/VIM4/wayland/src
CFLAGS = -Wall -O2 -fpic -shared -I$(TOOLCHAIN)/include
SOURCES = "gbm_bo_create_with_modifiers2.c"
BINARY = "mali_gbm_shim.so"

all:
	$(CC) $(CFLAGS) -o $(BINARY) $(SRC_DIR)/$(SOURCES)

clean:
	rm -f $(BINARY)
