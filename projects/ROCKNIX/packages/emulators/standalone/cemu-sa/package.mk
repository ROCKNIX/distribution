# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="cemu-sa"
PKG_VERSION="6f6c1299e29fa6e1062ae283a035b4ef787cc397"
PKG_LICENSE="MPL-2.0"
PKG_SITE="https://github.com/cemu-project/Cemu"
PKG_URL="${PKG_SITE}.git"
PKG_LONGDESC="KDE Extra CMake Modules"
PKG_DEPENDS_TARGET="toolchain libzip glslang glm curl rapidjson openssl boost libfmt pugixml libpng gtk3 wxwidgets SDL2 libsodium hidapi spirv-tools"

if [ "${DISPLAYSERVER}" = "x11" ]; then
  PKG_DEPENDS_TARGET+=" xwayland"
  PKG_CMAKE_OPTS_TARGET+=" -D ENABLE_WAYLAND=OFF"
elif [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland"
  PKG_CMAKE_OPTS_TARGET+=" -D ENABLE_WAYLAND=ON"
fi

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
  PKG_CMAKE_OPTS_TARGET+=" -D ENABLE_OPENGL=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -D ENABLE_OPENGL=OFF"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
  PKG_CMAKE_OPTS_TARGET+=" -D ENABLE_VULKAN=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -D ENABLE_VULKAN=OFF"
fi

PKG_CMAKE_OPTS_TARGET=" -DCMAKE_CXX_FLAGS="-Wno-changes-meaning" \
                        -DENABLE_VCPKG=OFF \
                        -DENABLE_DISCORD_RPC=OFF \
                        -DENABLE_SDL=ON \
                        -DENABLE_CUBEB=ON \
                        -DENABLE_WXWIDGETS=ON \
                        -DCMAKE_BUILD_TYPE=Release \
                        -DENABLE_FERAL_GAMEMODE=OFF"

post_unpack() {
  # Force build of cubeb submodule
  sed -e '/find_package(cubeb)/d' -i ${PKG_BUILD}/CMakeLists.txt
  # Fix glm linking
  sed -e "s#glm::glm#glm#" -i ${PKG_BUILD}/src/{Common,input}/CMakeLists.txt
}

pre_configure_target() {
  CXXFLAGS+=" -fpch-preprocess"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/bin/Cemu_* ${INSTALL}/usr/bin/cemu
    cp -a ${PKG_DIR}/scripts/start_cemu.sh    ${INSTALL}/usr/bin/

  mkdir -p ${INSTALL}/usr/config/Cemu
    cp -aL ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/Cemu

  mkdir -p ${INSTALL}/usr/share/Cemu
    cp -a ${PKG_BUILD}/bin/{gameProfiles,resources} ${INSTALL}/usr/share/Cemu
}
