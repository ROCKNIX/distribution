# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="decky-loader"
PKG_VERSION="v3.2.3"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/SteamDeckHomebrew/decky-loader"
PKG_URL="${PKG_SITE}/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain nodejs:host Python3:host Python3"
PKG_LONGDESC="A plugin loader for the Steam Deck."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  # Build the frontend
  # npm needs a home directory, we can't really do that with our build system (or at least Docker)
  export PKG_DECKY_LOADER_NPM_HOME="${PKG_BUILD}/npm-home"
  export PKG_DECKY_LOADER_NPM_CACHE="${PKG_BUILD}/npm-cache"
  mkdir -p ${PKG_DECKY_LOADER_NPM_HOME}
  mkdir -p ${PKG_DECKY_LOADER_NPM_CACHE}

  pushd ${PKG_BUILD}/frontend
    # Remove existing node_modules so we can handle the change from npm to pnpm 
    rm -rf node_modules

    # Download dependencies
    HOME="${PKG_DECKY_LOADER_NPM_HOME}" npm install pnpm --cache ${PKG_DECKY_LOADER_NPM_CACHE} --no-save --legacy-peer-deps
    HOME="${PKG_DECKY_LOADER_NPM_HOME}" npm exec -- pnpm i --frozen-lockfile --dangerously-allow-all-builds
    
    # Build
    HOME="${PKG_DECKY_LOADER_NPM_HOME}" npm exec -- pnpm build
  popd

  # "Build" the backend
  # We can't really build it... just install the dependencies preemptively
  export PKG_DECKY_LOADER_PIP_LIBS="${PKG_BUILD}/backend/lib"
  pip3 install \
    --target="${PKG_DECKY_LOADER_PIP_LIBS}" \
    --platform=manylinux2014_aarch64 \
    --python-version=313 \
    --implementation=cp \
    --only-binary=:all: \
      aiohttp aiohttp-jinja2 aiohttp-cors \
      setproctitle watchdog certifi packaging Jinja2 yarl frozenlist attrs multidict
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/decky-loader/
    cp -rf ${PKG_BUILD}/backend ${INSTALL}/usr/share/decky-loader/

  mkdir -p ${INSTALL}/usr/bin/
    cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin/
  
  chmod +x ${INSTALL}/usr/bin/*
}

post_install() {
  enable_service decky-loader.service
}