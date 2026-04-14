# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vita3k-sa"
PKG_VERSION="ba5c2029c96a08db63cfe04736156af481d9c137"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/Vita3K/Vita3K"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain libevdev SDL2 qt6 mesa libcom-err openssl zlib"
PKG_LONGDESC="PS VITA Emulator"
PKG_TOOLCHAIN="cmake"
PKG_GIT_CLONE_BRANCH="master"
GET_HANDLER_SUPPORT="git"
PKG_PATCH_DIRS+="${DEVICE}"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
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
                  ${CMAKE_EXTRA_OPTS}"
}

pre_make_target() {
  # Make sure cross compiliation doesn't fail catastrophically due to include path issues.
  find ${PKG_BUILD} -name flags.make -exec sed -i "s:isystem :I:g" \{} \;
  find ${PKG_BUILD} -name build.ninja -exec sed -i "s:isystem :I:g" \{} \;
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/vita3k
  mkdir -p ${INSTALL}/storage/bios/vita3k

  cp -f ${PKG_BUILD}/.${TARGET_NAME}/bin/Vita3K ${INSTALL}/usr/bin/vita3k-sa
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin/
  chmod 755 ${INSTALL}/usr/bin/*
  cp -f ${PKG_DIR}/config/config.yml ${INSTALL}/usr/config/vita3k/
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/bin/shaders-builtin ${INSTALL}/usr/config/vita3k/
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/bin/data ${INSTALL}/usr/config/vita3k/
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/bin/lang ${INSTALL}/usr/config/vita3k/
  cp -f ${PKG_DIR}/sources/vita-gamelist.txt ${INSTALL}/usr/config/vita3k/vita-gamelist.txt
}
