# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="fex-emu"
PKG_VERSION="e869aa644a16e4332cdc15c1ea0b4d13d482385d"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/FEX-Emu/FEX"
PKG_URL="https://github.com/FEX-Emu/FEX.git"
PKG_DEPENDS_TARGET="toolchain llvm:host fex-emu:host squashfs-tools zlib squashfuse alsa-lib libxcb wayland libglvnd libdrm libX11 libXrandr xorgproto qt6"
PKG_DEPENDS_HOST="toolchain:host llvm:host openssl:host"
PKG_LONGDESC="FEX-Emu is a fast x86/x86-64 emulator for AArch64"
PKG_TOOLCHAIN="manual"

FEX_LLVM_BIN="${TOOLCHAIN}/bin"
FEX_CLANG="${FEX_LLVM_BIN}/clang"
FEX_CLANGXX="${FEX_LLVM_BIN}/clang++"
FEX_CMAKE_BASE=(
  -DCMAKE_BUILD_TYPE=Release
  -DENABLE_LTO=True
  -DBUILD_TESTING=False
  -DBUILD_THUNKS=True
  -DCMAKE_INSTALL_PREFIX=/usr
  -DCMAKE_MAKE_PROGRAM=ninja
  -DCMAKE_C_COMPILER="${FEX_CLANG}"
  -DCMAKE_CXX_COMPILER="${FEX_CLANGXX}"
  
  # Make sure we pick up teh right llvm-ar and llvm-ranlib
  -DCMAKE_AR="${FEX_LLVM_BIN}/llvm-ar"
  -DCMAKE_RANLIB="${FEX_LLVM_BIN}/llvm-ranlib"
  -DCMAKE_C_COMPILER_AR="${FEX_LLVM_BIN}/llvm-ar"
  -DCMAKE_CXX_COMPILER_AR="${FEX_LLVM_BIN}/llvm-ar"
  -DCMAKE_ASM_COMPILER_AR="${FEX_LLVM_BIN}/llvm-ar"
  -DCMAKE_C_COMPILER_RANLIB="${FEX_LLVM_BIN}/llvm-ranlib"
  -DCMAKE_CXX_COMPILER_RANLIB="${FEX_LLVM_BIN}/llvm-ranlib"
  -DCMAKE_ASM_COMPILER_RANLIB="${FEX_LLVM_BIN}/llvm-ranlib"
)

FEX_CMAKE_OPTS=(
  "${FEX_CMAKE_BASE[@]}"
  -DUSE_LINKER=lld
  -DENABLE_ASSERTIONS=False
  -DCMAKE_LINKER="${FEX_LLVM_BIN}/ld.lld"
)

make_host() {
  mkdir -p "${PKG_BUILD}/.${HOST_NAME}"
  cd "${PKG_BUILD}"

  local -a host_opts=(
    -G Ninja
    -S "${PKG_BUILD}"
    -B "${PKG_BUILD}/.${HOST_NAME}"
    "${FEX_CMAKE_BASE[@]}"
    -DUSE_LINKER="${FEX_LLVM_BIN}/ld.lld"
    -DBUILD_FEXCONFIG=False
    -DTHUNKGEN_ONLY=True
    -DCMAKE_ASM_COMPILER="${FEX_CLANG}"
    -DCMAKE_PREFIX_PATH="${TOOLCHAIN}"
    -DCLANG_EXEC_PATH="${FEX_CLANG}"
    -DENABLE_X86_HOST_DEBUG=True
  )
  cmake "${host_opts[@]}"
  cd "${PKG_BUILD}/.${HOST_NAME}"
  ninja thunkgen
}

make_target() {
  local _v
  for _v in CFLAGS CXXFLAGS LDFLAGS; do
    export ${_v}="$(echo ${!_v} | sed 's/-mabi=lp64//g; s/-mtune=[^ ]*//g')"
  done
  export USER="${USER:-$(whoami)}"
  export HOME=${PKG_BUILD}/nix
  curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
  . "${HOME}/.nix-profile/etc/profile.d/nix.sh"
  # Pin nixpkgs: the thunk toolchain and x86 dev rootfs come from
  # <nixpkgs>; unpinned, they roll with the channel on every build and
  # header drift breaks the generated thunks (nixos-unstable 2026-08-05)
  export NIX_PATH="nixpkgs=https://github.com/NixOS/nixpkgs/archive/ee67c8504dafc87ba63e862d76558384d10e1e8c.tar.gz"

  mkdir -p "${PKG_BUILD}/.${TARGET_NAME}"
  cd "${PKG_BUILD}/.${TARGET_NAME}"

  case ${TARGET_CPU} in
    cortex-x3|cortex-x4)
      TUNE_CPU="cortex-a78"
      ;;
    *)
      TUNE_CPU="${TARGET_CPU##*.}"
      ;;
  esac

  # thunkgen host-parse system headers. --sysroot instead of -isystem so the
  # guest parse's own --sysroot (appended later, last one wins) overrides it;
  # libstdc++ passed explicitly since it is not discoverable under a sysroot.
  local cxxdir
  cxxdir=$(ls -d "${TOOLCHAIN}/${TARGET_NAME}/include/c++/"* | sort -V | tail -n1)
  export THUNKGEN_EXTRA_FLAGS="--sysroot ${SYSROOT_PREFIX} -isystem ${cxxdir} -isystem ${cxxdir}/${TARGET_NAME}"

  local -a tgt_opts=(
    -G Ninja
    -S "${PKG_BUILD}"
    -B "${PKG_BUILD}/.${TARGET_NAME}"
    -DCMAKE_SYSTEM_NAME=Linux
    -DCMAKE_SYSTEM_PROCESSOR=aarch64
    -DCMAKE_C_COMPILER_TARGET=aarch64-rocknix-linux-gnu
    -DCMAKE_CXX_COMPILER_TARGET=aarch64-rocknix-linux-gnu
    -DCMAKE_SYSROOT="${SYSROOT_PREFIX}"
    -DCMAKE_FIND_ROOT_PATH="${SYSROOT_PREFIX}"
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY
    -DBUILD_FEXCONFIG=True
    "${FEX_CMAKE_OPTS[@]}"
    -DGENERATOR_EXE="${TOOLCHAIN}/usr/bin/thunkgen"
    -DCMAKE_INSTALL_LIBDIR=lib
    -DQT_HOST_PATH="${TOOLCHAIN}/usr/local/qt6"
    -DTUNE_CPU="${TUNE_CPU}"
  )
  cmake "${tgt_opts[@]}"
  # aarch64 build host: x86_64 thunk descriptor needs the cross prefix, not bare clang
  if [ "$(uname -m)" = "aarch64" ]; then
    sed -i 's#/bin/clang)#/bin/x86_64-unknown-linux-gnu-clang)#; s#/bin/clang++)#/bin/x86_64-unknown-linux-gnu-clang++)#' "${PKG_BUILD}/Data/nix/LibraryForwarding/shell.nix"
  fi
  bash "${PKG_BUILD}/Data/nix/cmake_enable_libfwd.sh"
  ninja
}

makeinstall_target() {
  cd "${PKG_BUILD}/.${TARGET_NAME}"
  DESTDIR="${INSTALL}" ninja install
  mkdir -p "${INSTALL}/usr/config/fex-emu"
  cp -rf "${PKG_DIR}/config/fex-emu/." "${INSTALL}/usr/config/fex-emu"
  cp -rf "${PKG_DIR}/config/gptk" "${INSTALL}/usr/config/fex-emu"
  mkdir -p "${INSTALL}/usr/config/modules"
  cp -rf "${PKG_DIR}/scripts/"* "${INSTALL}/usr/config/modules"
  cp "${TOOLCHAIN}/lib/libvulkan_freedreno.so" "${INSTALL}/usr/share/fex-emu/"
}

makeinstall_host() {
  mkdir -p "${TOOLCHAIN}/usr/bin"
  cp -av "${PKG_BUILD}/.${HOST_NAME}/Bin/thunkgen" "${TOOLCHAIN}/usr/bin"
}
