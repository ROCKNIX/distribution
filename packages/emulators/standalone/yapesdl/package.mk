# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="yapesdl"
PKG_VERSION="7050ffc0702bab2f38111029aad8bf520ad22feb"
PKG_LICENSE="GPL2"
PKG_SITE="https://github.com/calmopyrin/yapesdl"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_image libpng zlib"
PKG_LONGDESC="Yet Another Plus/4 Emulator"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS+=(
  "CC=${CC}"
  "CXX=${CXX}"
  "CFLAGS=${TARGET_CFLAGS}"
  "CXXFLAGS=${TARGET_CXXFLAGS}"
  "LDFLAGS=${TARGET_LDFLAGS}"
)

# This hook runs after unpacking and BEFORE building.
# It completely OVERWRITES the original Makefile with a clean, working one.
post_unpack() {
  cat > ${PKG_BUILD}/Makefile << 'EOF'
#
# Clean Makefile for yapesdl on Rocknix
# This Makefile is designed to work with a build system.
#

# 1. Define Executable Name
EXENAME = yapesdl

# 2. Define Source Files
# C++ sources
CPP_FILES = 1541mem.cpp archdep.cpp Cia.cpp cpu.cpp dis.cpp diskfs.cpp dos.cpp drive.cpp FdcGcr.cpp \
			 iec.cpp interface.cpp keyboard.cpp keys64.cpp keysvic.cpp main.cpp monitor.cpp \
			 prg.cpp SaveState.cpp serial.cpp Sid.cpp sound.cpp tape.cpp tcbm.cpp tedmem.cpp \
			 tedsound.cpp Via.cpp vicmem.cpp vic2mem.cpp video.cpp

# C sources for minizip support
C_FILES = zlib/unzip.c zlib/ioapi.c

# Combine all source files into object files
OBJECTS = $(CPP_FILES:.cpp=.o) $(C_FILES:.c=.o)

# 3. Define Build Rules using variables passed by the build system
# These CFLAGS/CXXFLAGS will come from Rocknix's PKG_MAKE_OPTS
# and will contain correct -I paths for SDL2, etc.
# We also add flags needed by yapesdl (-w, -DZIP_SUPPORT).
YAPESDL_CFLAGS = $(CFLAGS) -w -DZIP_SUPPORT
YAPESDL_CXXFLAGS = $(CXXFLAGS) -w -DZIP_SUPPORT

# Default target
all: $(EXENAME)

# Rule for linking the final executable
# This uses LDFLAGS from Rocknix (for -L paths) and explicitly links libraries.
$(EXENAME): $(OBJECTS)
	$(CXX) $(LDFLAGS) -o $(EXENAME) $(OBJECTS) -lSDL2 -lstdc++ -lz -lm

# Rule for compiling C++ files
.cpp.o:
	$(CXX) $(YAPESDL_CXXFLAGS) -c $< -o $@

# Rule for compiling C files
.c.o:
	$(CC) $(YAPESDL_CFLAGS) -c $< -o $@

# Clean rule
clean:
	rm -f $(OBJECTS) $(EXENAME)

EOF
}

makeinstall_target() {
  install -Dm755 yapesdl ${INSTALL}/usr/bin/yapesdl
  install -Dm755 $PKG_DIR/scripts/start_yapesdl.sh ${INSTALL}/usr/bin/start_yapesdl.sh
}