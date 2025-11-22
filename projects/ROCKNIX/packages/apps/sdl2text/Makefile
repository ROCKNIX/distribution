# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

CXX ?= gcc
CCFLAGS = -W -Wall -std=c++11 `sdl2-config --cflags`

BINARY = sdl2text
LIBRARIES = -lSDL2 -lSDL2_ttf
SOURCES = "sdl2text.cpp"

all:
	$(CXX) $(CFLAGS) $(SOURCES) -o $(BINARY) $(LIBRARIES)

clean:
	rm -f $(BINARY)
