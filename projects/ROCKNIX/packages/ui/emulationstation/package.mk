# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="emulationstation"
PKG_VERSION="f1ae6bc25c90972d304a3fd23585a77d844ed894"
PKG_GIT_CLONE_BRANCH="test/qa-integration"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/maxengel/emulationstation-next"
PKG_URL="${PKG_SITE}.git"
# noto-sans-cjk came from upstream 2026-09, and poppler with the PDF support
# upstream's EmulationStation gained (e0e8b7ac33); the fork builds its own ES
# from its own branch, so the clone form stays.
PKG_DEPENDS_TARGET="boost toolchain SDL2 freetype curl freeimage bash rapidjson SDL2_mixer fping p7zip alsa vlc drm_tool poppler pugixml noto-sans-cjk ${OPENGLES}"
PKG_NEED_UNPACK="busybox"
PKG_LONGDESC="Emulationstation emulator frontend"
PKG_BUILD_FLAGS="-gold"
GET_HANDLER_SUPPORT="git"

PKG_CMAKE_OPTS_TARGET+=" -DROCKNIX=1 \
                         -DDISABLE_KODI=1 \
                         -DENABLE_FILEMANAGER=0 \
                         -DCEC=0 \
                         -DENABLE_PULSE=1 \
                         -DUSE_SYSTEM_PUGIXML=1 \
                         -DGLES3=1"

# The ScreenScraper developer pair is entered on the device, not compiled in,
# so no fork image carries a key (#64). A SCREENSCRAPER_DEV_LOGIN in the build
# environment still wins and hides the rows.
PKG_CMAKE_OPTS_TARGET+=" -DSCREENSCRAPER_RUNTIME_DEV_LOGIN=1"

# Upstream replaced the S922X test with a build option (2026-09).
[ "${BATTERYPLUS_SUPPORT}" = "yes" ] && PKG_CMAKE_OPTS_TARGET+=" -DBATTERYPLUS=1"

pre_configure_target() {
  for key in SCREENSCRAPER_DEV_LOGIN \
             GAMESDB_APIKEY \
             CHEEVOS_DEV_LOGIN; do
    if [ -z "${!key}" ]; then
      echo "WARNING: ${key} not declared, will not build support."
    else
      # The name, never the value: a developer password or an API key does
      # not belong in a build log that gets pasted into an issue.
      echo "USING: ${key} (set)"
    fi
  done

  export DEVICE=$(echo ${DEVICE^^} | sed "s#-#_##g")
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/locale
    cp -a ${PKG_BUILD}/locale/lang/* ${INSTALL}/usr/config/locale

    # Pre-generate default (en_US.UTF-8) locale for lower-end devices to speed up first boot
    # This saves a minute or two on RK3326 in a cost of about 1 MB of SYSTEM size
    # Copy-paste of a locale generating part of es_settings script
    I18NPATH=$(get_install_dir glibc)/usr/share/i18n/locales/ \
      localedef --force --verbose --inputfile=en_US --charmap=UTF-8 \
      ${INSTALL}/usr/config/locale/en_US.UTF-8 || true

  mkdir -p ${INSTALL}/usr/config/emulationstation
    cp -a ${PKG_DIR}/config/common/*.cfg ${INSTALL}/usr/config/emulationstation
    rm -f ${INSTALL}/usr/config/emulationstation/resources/logo.png

  mkdir -p ${INSTALL}/usr/config/emulationstation/resources
    cp -a ${PKG_BUILD}/resources/* ${INSTALL}/usr/config/emulationstation/resources
    rm -f ${INSTALL}/usr/config/emulationstation/resources/DroidSansFallbackFull.ttf
    ln -sf /usr/share/fonts/truetype/noto-cjk/NotoSansCJKsc-Regular.otf \
      ${INSTALL}/usr/config/emulationstation/resources/DroidSansFallbackFull.ttf

  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/es_settings ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/start_es.sh ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/serial_number_check ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/bin
    #ln -sf /storage/.config/emulationstation/resources ${INSTALL}/usr/bin/resources
    cp -a ${PKG_BUILD}/emulationstation ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/etc
    ln -sf /storage/.cache/system_timezone ${INSTALL}/etc/timezone

  mkdir -p ${INSTALL}/etc/emulationstation
    ln -sf /storage/.config/emulationstation/themes ${INSTALL}/etc/emulationstation/themes
    ln -sf ${INSTALL}/usr/config/emulationstation/es_systems.cfg ${INSTALL}/etc/emulationstation/es_systems.cfg


  # If we're not an emulation device, ES may still be installed so we need a default config.
  if [[ "${EMULATION_DEVICE}" == "no" || "${BASE_ONLY}" == "true" ]]; then
    cat <<EOF >${INSTALL}/usr/config/emulationstation/es_systems.cfg
<?xml version="1.0" encoding="UTF-8"?>
<systemList>
        <system>
                <name>tools</name>
                <fullname>Tools</fullname>
                <manufacturer>ROCKNIX</manufacturer>
                <release>2024</release>
                <hardware>system</hardware>
                <path>/storage/.config/modules</path>
                <extension>.sh</extension>
                <command>%ROM%</command>
                <platform>tools</platform>
                <theme>tools</theme>
        </system>
</systemList>
EOF
  fi

  #Delete all vulkan options from es_features when vulkan is not present
  if [ ! "${VULKAN_SUPPORT}" = "yes" ]; then
    xmlstarlet ed --inplace -d '//choice[contains(@name, "vulkan")]' ${INSTALL}/usr/config/emulationstation/es_features.cfg
  fi
}


post_install() {
  mkdir -p ${INSTALL}/usr/share
    ln -sf /storage/.config/locale ${INSTALL}/usr/share/locale

  mkdir -p ${INSTALL}/usr/lib
    ln -sf /usr/share/locale ${INSTALL}/usr/lib/locale

  mkdir -p ${INSTALL}/usr/config/emulationstation
    ln -sf /usr/share/locale  ${INSTALL}/usr/config/emulationstation/locale
}
