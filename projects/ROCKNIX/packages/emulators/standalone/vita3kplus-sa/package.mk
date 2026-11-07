# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vita3kplus-sa"
PKG_VERSION="5581fb1151451fbedc64265d01742483908b87b4"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/nckstwrt/Vita3K-Plus"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain libevdev SDL2 qt6 mesa libcom-err openssl zlib"
PKG_LONGDESC="PS VITA Emulator (Vita3K-Plus fork)"
PKG_TOOLCHAIN="cmake"
PKG_GIT_CLONE_BRANCH="all-enhancements"

PKG_PATCH_DIRS+="${DEVICE}"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
fi

pre_configure_target() {
  case ${TARGET_ARCH} in
    aarch64)
      CMAKE_EXTRA_OPTS="-DXXHASH_BUILD_XXHSUM=ON \
                        -DXXH_X86DISPATCH_ALLOW_AVX=OFF"
      ;;
    *)
      CMAKE_EXTRA_OPTS="-DXXH_X86DISPATCH_ALLOW_AVX=ON"
      ;;
  esac

  PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                  -DBUILD_SHARED_LIBS=OFF \
                  -DUSE_DISCORD_RICH_PRESENCE=OFF \
                  -DUSE_VITA3K_UPDATE=OFF \
                  -DUSE_LTO=NEVER \
                  ${CMAKE_EXTRA_OPTS}"
}

pre_make_target() {
  # Make sure cross compiliation doesn't fail catastrophically due to include path issues.
  find ${PKG_BUILD} -name flags.make -exec sed -i "s:isystem :I:g" \{} \;
  find ${PKG_BUILD} -name build.ninja -exec sed -i "s:isystem :I:g" \{} \;
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/vita3kplus

  cp -f ${PKG_BUILD}/.${TARGET_NAME}/bin/Vita3K ${INSTALL}/usr/bin/vita3kplus-sa
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin/
  chmod 755 ${INSTALL}/usr/bin/*
  cp -f ${PKG_DIR}/config/config.yml ${INSTALL}/usr/config/vita3kplus/
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/bin/shaders-builtin ${INSTALL}/usr/config/vita3kplus/
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/bin/data ${INSTALL}/usr/config/vita3kplus/
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/bin/translations ${INSTALL}/usr/config/vita3kplus/
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/bin/icons ${INSTALL}/usr/config/vita3kplus/
}
