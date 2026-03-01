# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

CXX ?= gcc
CCFLAGS = -W -Wall -std=c++11 `sdl2-config --cflags`

BINARY = control-gen
LIBRARIES = -lSDL2
SOURCES = "control-gen.cpp"

all:
	$(CXX) $(CFLAGS) $(SOURCES) -o $(BINARY) $(LIBRARIES)

clean:
	rm -f $(BINARY)
