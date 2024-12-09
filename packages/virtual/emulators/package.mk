# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="emulators"
PKG_LICENSE="GPLv2"
PKG_SITE="https://rocknix.org"
PKG_SECTION="emulation" # Do not change to virtual or makeinstall_target will not execute.
PKG_LONGDESC="Emulation metapackage."
PKG_TOOLCHAIN="manual"

PKG_EMUS="amiberry duckstation-sa flycast-sa gzdoom-sa hatarisa hypseus-singe moonlight mupen64plus-sa openbor pico-8 ppsspp-sa vice-sa"

PKG_RETROARCH="core-info libretro-database retroarch retroarch-assets retroarch-joypads retroarch-overlays slang-shaders"

LIBRETRO_CORES="81-lr a5200-lr arduous-lr atari800-lr beetle-gba-lr beetle-lynx-lr beetle-ngp-lr beetle-pce-lr beetle-pce-fast-lr    \
                beetle-pcfx-lr bsnes-mercury-accuracy-lr bsnes-mercury-balanced-lr bsnes-mercury-performance-lr beetle-supafaust-lr  \
                beetle-supergrafx-lr beetle-vb-lr beetle-wswan-lr bluemsx-lr cap32-lr crocods-lr daphne-lr doublecherrygb-lr         \
                dosbox-svn-lr dosbox-pure-lr duckstation-lr easyrpg-lr emuscv-lr fake08-lr fbalpha2012-lr                            \
                fbalpha2019-lr fbneo-lr fceumm-lr flycast2021-lr fmsx-lr freechaf-lr freeintv-lr freej2me-lr fuse-lr gambatte-lr     \
                gearboy-lr gearcoleco-lr gearsystem-lr genesis-plus-gx-lr genesis-plus-gx-wide-lr gw-lr handy-lr hatari-lr idtech-lr \
                jaxe-lr mame-lr mame2003-plus-lr mame2010-lr mame2015-lr melonds-lr melonds-ds-lr mesen-lr mgba-lr minivmac-lr       \
                mojozork-lr mu-lr mupen64plus-lr mupen64plus-nx-lr neocd_lr nestopia-lr np2kai-lr o2em-lr opera-lr parallel-n64-lr   \
                pcsx_rearmed-lr picodrive-lr pokemini-lr potator-lr prosystem-lr puae-lr puae2021-lr px68k-lr quasi88-lr quicknes-lr \
                race-lr same_cdi-lr sameboy-lr sameduck-lr scummvm-lr smsplus-gx-lr snes9x-lr snes9x2002-lr snes9x2005_plus-lr       \
                snes9x2010-lr stella-lr swanstation-lr tgbdual-lr theodore-lr tic80-lr uzem-lr vba-next-lr vbam-lr vecx-lr vice-lr   \
                vircon32-lr virtualjaguar-lr xmil-lr wasm4-lr yabasanshiro-lr"

### Emulators or cores for specific devices
case "${DEVICE}" in
  AMD64)
    [ "${ENABLE_32BIT}" == "true" ] && EMUS_32BIT="wine"
    PKG_EMUS+=" cemu-sa dolphin-sa lime3ds-sa mednafen melonds-sa minivmacsa mupen64plus-sa nanoboyadvance-sa pcsx2-sa     \
               rpcs3-sa scummvmsa vita3k-sa xemu-sa"
    LIBRETRO_CORES+=" beetle-psx-lr beetle-saturn-lr bsnes-lr bsnes-hd-lr desmume-lr dolphin-lr flycast-lr lrps2-lr panda3ds-lr play-lr"
  ;;
  RK3588)
    [ "${ENABLE_32BIT}" == "true" ] && EMUS_32BIT="box86 desmume-lr gpsp-lr pcsx_rearmed-lr wine"
    PKG_EMUS+=" aethersx2-sa box64 dolphin-sa drastic-sa mednafen melonds-sa portmaster scummvmsa supermodel-sa yabasanshiro-sa"
    LIBRETRO_CORES+=" beetle-psx-lr beetle-saturn-lr bsnes-lr bsnes-hd-lr dolphin-lr flycast-lr geolith-lr panda3ds-lr pcsx_rearmed-lr uae4arm"
    PKG_RETROARCH+=" retropie-shaders"
  ;;
  RK3399)
    [ "${ENABLE_32BIT}" == "true" ] && EMUS_32BIT="box86 desmume-lr gpsp-lr pcsx_rearmed-lr"
    PKG_EMUS+=" aethersx2-sa box64 dolphin-sa drastic-sa mednafen melonds-sa nanoboyadvance-sa portmaster scummvmsa yabasanshiro-sa"
    LIBRETRO_CORES+=" beetle-psx-lr bsnes-lr bsnes-hd-lr dolphin-lr geolith-lr flycast-lr pcsx_rearmed-lr uae4arm"
    PKG_RETROARCH+=" retropie-shaders"
  ;;
  RK3566*)
    [ "${ENABLE_32BIT}" == "true" ] && EMUS_32BIT="box86 desmume-lr gpsp-lr pcsx_rearmed-lr wine"
    PKG_DEPENDS_TARGET+=" common-shaders glsl-shaders"
    PKG_EMUS+=" box64 dolphin-sa drastic-sa mednafen melonds-sa portmaster scummvmsa yabasanshiro-sa"
    LIBRETRO_CORES+=" dolphin-lr flycast-lr geolith-lr uae4arm"
    PKG_RETROARCH+=" retropie-shaders"
  ;;
  S922X)
    [ "${ENABLE_32BIT}" == "true" ] && EMUS_32BIT="box86 pcsx_rearmed-lr wine"
    PKG_EMUS+=" aethersx2-sa box64 dolphin-sa drastic-sa portmaster scummvmsa yabasanshiro-sa"
    LIBRETRO_CORES+=" beetle-psx-lr beetle-saturn-lr bsnes-lr bsnes-hd-lr dolphin-lr geolith-lr flycast-lr lime3ds-sa uae4arm"
    PKG_RETROARCH+=" retropie-shaders"
  ;;
  RK3326)
    [ "${ENABLE_32BIT}" == "true" ] && EMUS_32BIT="box86 desmume-lr gpsp-lr pcsx_rearmed-lr wine"
    PKG_DEPENDS_TARGET+=" common-shaders glsl-shaders"
    PKG_EMUS+=" box64 drastic-sa mednafen portmaster scummvmsa yabasanshiro-sa"
    LIBRETRO_CORES+=" flycast-lr flycast2021-lr geolith-lr uae4arm"
    PKG_RETROARCH+=" retropie-shaders"
  ;;
  H700)
    [ "${ENABLE_32BIT}" == "true" ] && EMUS_32BIT="box86 desmume-lr gpsp-lr pcsx_rearmed-lr wine"
    PKG_DEPENDS_TARGET+=" common-shaders glsl-shaders"
    PKG_EMUS+=" box64 drastic-sa mednafen portmaster scummvmsa yabasanshiro-sa"
    LIBRETRO_CORES+=" flycast-lr flycast2021-lr geolith-lr uae4arm"
    PKG_RETROARCH+=" retropie-shaders"
  ;;
  SD865)
    [ "${ENABLE_32BIT}" == "true" ] && EMUS_32BIT="box86 desmume-lr gpsp-lr pcsx_rearmed-lr wine"
    PKG_EMUS+=" aethersx2-sa box64 dolphin-sa drastic-sa lime3ds-sa melonds-sa portmaster rpcs3-sa scummvmsa supermodel-sa \
               yabasanshiro-sa xemu-sa"
    LIBRETRO_CORES+=" beetle-psx-lr beetle-saturn-lr bsnes-lr bsnes-hd-lr dolphin-lr flycast-lr geolith-lr panda3ds-lr pcsx_rearmed-lr uae4arm kronos-lr"
    PKG_RETROARCH+=" retropie-shaders"
  ;;
esac

# Split building emulators into 2 stages, needed to fit the jobs into the 6 hour GH runner time limit.
case "${TARGET_TYPE}" in
  cores_only)
    PKG_DEPENDS_TARGET+=" ${LIBRETRO_CORES}"
  ;;
  emus_only)
    PKG_DEPENDS_TARGET+=" ${PKG_EMUS} ${EMUS_32BIT} ${PKG_RETROARCH}"
  ;;
  *)
    PKG_DEPENDS_TARGET+=" ${PKG_EMUS} ${EMUS_32BIT} ${PKG_RETROARCH} ${LIBRETRO_CORES}"
  ;;
esac

install_script() {
  if [ ! -d "${INSTALL}/usr/config/modules" ]
  then
    mkdir -p ${INSTALL}/usr/config/modules
  fi
  cp -rf ${PKG_DIR}/sources/"${1}" ${INSTALL}/usr/config/modules
  chmod 0755 ${INSTALL}/usr/config/modules/"${1}"
}

makeinstall_target() {
  ### README BEFORE EDITING
  ###
  ### When adding new emulators to this package, it is now necessary to add
  ### your emulator below for it to appear in EmulationStation as es_systems.cfg
  ### is now automatically generated when this package is built.
  ###
  ### Add your cores BEFORE calling the function to add a new system, when the
  ### system is generated and added to ES the cores need to already be defined.
  ###
  ### Only ONE core per system can be set as the default, setting multiple cores
  ### will result in a build failure.
  ###
  ### add_emu_core schema:
  ###
  ### System | Emulator | Core | Default
  ### 3do      retroarch  opera  true
  ###

  ### Flush cache from previous builds
  clean_es_cache
  clean_doc_cache

  ### Add bezels directory
  add_system_dir /storage/roms/bezels

  ### Add BIOS directory
  add_system_dir /storage/roms/bios

  ### Add music directory
  add_system_dir /storage/roms/music

  ### Add save states directory
  add_system_dir /storage/roms/savestates

  ### Add themes directory
  add_system_dir /storage/roms/themes

  ### Apply documentation header
  start_system_doc

  ### Panasonic 3DO
  add_emu_core 3do retroarch opera true
  add_es_system 3do

  ### Nintendo 3DS
  case ${DEVICE} in
    AMD64|S922X|SD865)
      add_emu_core 3ds lime3ds lime3ds-sa true
      add_emu_core 3ds retroarch panda3ds false
      add_es_system 3ds
    ;;
    RK3588)
      add_emu_core 3ds retroarch panda3ds true
      add_es_system 3ds
    ;;
  esac

  ### Commodore Amiga
  case ${DEVICE} in
    RK35*|RK3326|RK3399|H700|SD865)
      add_emu_core amiga retroarch puae2021 true
      add_emu_core amiga retroarch puae false
    ;;
    *)
      add_emu_core amiga retroarch puae true
      add_emu_core amiga retroarch puae2021 false
    ;;
  esac
  case ${TARGET_ARCH} in
    aarch64)
      add_emu_core amiga amiberry amiberry false
      add_emu_core amiga retroarch uae4arm false
    ;;
  esac
  add_es_system amiga

  ### Commodore Amiga CD32
  case ${DEVICE} in
    RK35*|RK3326|RK3399|H700|SD865)
      add_emu_core amigacd32 retroarch puae2021 true
      add_emu_core amigacd32 retroarch puae false
    ;;
    *)
      add_emu_core amigacd32 retroarch puae true
      add_emu_core amigacd32 retroarch puae2021 false
    ;;
  esac
  case ${TARGET_ARCH} in
    aarch64)
      add_emu_core amigacd32 retroarch uae4arm false
    ;;
  esac
  add_es_system amigacd32

  ### Amstrad CPC
  add_emu_core amstradcpc retroarch crocods true
  add_emu_core amstradcpc retroarch cap32 false
  add_es_system amstradcpc

  ### Arcade
  add_emu_core arcade retroarch mame2003_plus true
  add_emu_core arcade retroarch mame2010 false
  add_emu_core arcade retroarch mame2015 false
  add_emu_core arcade retroarch fbneo false
  add_emu_core arcade retroarch fbalpha2012 false
  add_emu_core arcade retroarch fbalpha2019 false
  add_emu_core arcade retroarch mame false
  add_es_system arcade

  ### Arduboy
  add_emu_core arduboy retroarch arduous true
  add_es_system arduboy

  ### Atari 2600 Libretro
  add_emu_core atari2600 retroarch stella true
  add_es_system atari2600

  ### Atari 5200 Libretro
  add_emu_core atari5200 retroarch a5200 true
  add_emu_core atari5200 retroarch atari800 false
  add_es_system atari5200

  ### Atari 7800
  add_emu_core atari7800 retroarch prosystem true
  add_es_system atari7800

  ## Atari 800
  add_emu_core atari800 retroarch atari800 true
  add_es_system atari800

  ## Atari ST
  add_emu_core atarist retroarch hatari true
  add_emu_core atarist hatarisa hatarisa false
  add_es_system atarist
  install_script "Start HATARISA.sh"

  ## Sammy Atomiswave
  case ${DEVICE} in
    RK35*)
      add_emu_core atomiswave retroarch flycast2021 true
      add_emu_core atomiswave retroarch flycast false
      add_emu_core atomiswave flycast flycast-sa false
    ;;
    RK33*)
      add_emu_core atomiswave retroarch flycast2021 false
      add_emu_core atomiswave flycast flycast-sa false
      add_emu_core atomiswave retroarch flycast true
    ;;
    S922X|SD865)
      add_emu_core atomiswave retroarch flycast2021 false
      add_emu_core atomiswave flycast flycast-sa true
      add_emu_core atomiswave retroarch flycast false
    ;;
    *)
      add_emu_core atomiswave retroarch flycast true
      add_emu_core atomiswave flycast flycast-sa false
    ;;
  esac
  add_es_system atomiswave

  ### Fairchild Channel F
  add_emu_core channelf retroarch freechaf true
  add_es_system channelf

  ### ColecoVision
  add_emu_core colecovision retroarch gearcoleco true
  add_emu_core colecovision retroarch bluemsx false
  add_emu_core colecovision retroarch smsplus false
  add_es_system colecovision

  ### Commodore 128
  add_emu_core c128 retroarch vice_x128 true
  add_emu_core c128 vicesa x128 false
  add_es_system c128

  ### Commodore 16
  add_emu_core c16 retroarch vice_xplus4 true
  add_emu_core c16 vicesa xplus4 false
  add_es_system c16

  ### Commodore 64
  add_emu_core c64 retroarch vice_x64 true
  add_emu_core c64 vicesa x64sc false
  add_es_system c64

  ### Commodore PET
  add_emu_core pet retroarch vice_xpet true
  add_es_system pet

  ### Commodore VIC-20
  add_emu_core vic20 retroarch vice_xvic true
  add_emu_core vic20 vicesa xvic false
  add_es_system vic20

  ### Capcom Playsystem 1
  add_emu_core cps1 retroarch fbneo true
  add_emu_core cps1 retroarch mame2003_plus false
  add_emu_core cps1 retroarch mame2010 false
  add_emu_core cps1 retroarch fbalpha2012 false
  case ${TARGET_ARCH} in
    aarch64)
      add_emu_core cps1 AdvanceMame AdvanceMame false
    ;;
  esac
  add_es_system cps1

  ### Capcom Playsystem 2
  add_emu_core cps2 retroarch fbneo true
  add_emu_core cps2 retroarch mame2003_plus false
  add_emu_core cps2 retroarch mame2010 false
  add_emu_core cps2 retroarch fbalpha2012 false
  case ${TARGET_ARCH} in
    aarch64)
      add_emu_core cps2 AdvanceMame AdvanceMame false
    ;;
  esac
  add_es_system cps2

  ### Capcom Playsystem 3
  add_emu_core cps3 retroarch fbneo true
  add_emu_core cps3 retroarch mame2003_plus false
  add_emu_core cps3 retroarch mame2010 false
  add_emu_core cps3 retroarch fbalpha2012 false
  case ${TARGET_ARCH} in
    aarch64)
      add_emu_core cps3 AdvanceMame AdvanceMame false
    ;;
  esac
  add_es_system cps3

  ### Daphne
  add_emu_core daphne hypseus-singe hypseus-singe true
  add_emu_core daphne retroarch daphne false
  add_es_system daphne

  ### Sega Dreamcast
  case ${DEVICE} in
    RK35*)
      add_emu_core dreamcast retroarch flycast2021 true
      add_emu_core dreamcast retroarch flycast false
      add_emu_core dreamcast flycast flycast-sa false
    ;;
    RK33*|H700)
      add_emu_core dreamcast retroarch flycast2021 false
      add_emu_core dreamcast flycast flycast-sa false
      add_emu_core dreamcast retroarch flycast true
    ;;
    S922X|SD865)
      add_emu_core dreamcast retroarch flycast2021 false
      add_emu_core dreamcast flycast flycast-sa true
      add_emu_core dreamcast retroarch flycast false
    ;;
    *)
      add_emu_core dreamcast retroarch flycast2021 false
      add_emu_core dreamcast retroarch flycast true
      add_emu_core dreamcast flycast flycast-sa false
    ;;
  esac
  add_es_system dreamcast

  ### EasyRPG
  add_emu_core easyrpg retroarch easyrpg true
  add_es_system easyrpg

  ### Nintendo Famicom
  add_emu_core famicom retroarch nestopia true
  add_emu_core famicom retroarch fceumm false
  add_emu_core famicom retroarch quicknes false
  add_emu_core famicom retroarch mesen false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core famicom mednafen nes false
    ;;
  esac
  add_es_system famicom

  ### Nintendo Famicom Disk System
  add_emu_core fds retroarch nestopia true
  add_emu_core fds retroarch fceumm false
  add_emu_core fds retroarch quicknes false
  add_emu_core fds retroarch mesen false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core fds mednafen nes false
    ;;
  esac
  add_es_system fds

  ### Final Burn Neo
  add_emu_core fbn retroarch fbneo true
  add_emu_core fbn retroarch mame2003_plus false
  add_emu_core fbn retroarch mame2010 false
  add_emu_core fbn retroarch mame2015 false
  add_emu_core fbn retroarch mame false
  add_emu_core fbn retroarch fbalpha2012 false
  add_emu_core fbn retroarch fbalpha2019 false
  add_es_system fbn

  ### iD Software game engines
  add_emu_core idtech retroarch idtech
  add_es_system idtech
  install_script "Scan id Tech Files.sh"

  ### Apple Macintosh Plus
  add_emu_core macintosh retroarch minivmac true
  add_es_system macintosh

  ### Nintendo Game and Watch
  add_emu_core gameandwatch retroarch gw
  add_emu_core gameandwatch retroarch mame
  add_es_system gameandwatch

  ### Nintendo GameBoy
  add_emu_core gb retroarch gambatte true
  add_emu_core gb retroarch sameboy false
  add_emu_core gb retroarch gearboy false
  add_emu_core gb retroarch tgbdual false
  add_emu_core gb retroarch mgba false
  add_emu_core gb retroarch vbam false
  add_emu_core gb retroarch DoubleCherryGB false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core gb mednafen gb false
    ;;
  esac
  add_es_system gb

  ### Nintendo GameBoy Hacks
  add_emu_core gbh retroarch gambatte true
  add_emu_core gbh retroarch sameboy false
  add_emu_core gbh retroarch gearboy false
  add_emu_core gbh retroarch tgbdual false
  add_emu_core gbh retroarch mgba false
  add_emu_core gbh retroarch vbam false
  add_emu_core gbh retroarch DoubleCherryGB false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core gbh mednafen gb false
    ;;
  esac
  add_es_system gbh

  ### Nintendo GameBoy Advance
  add_emu_core gba retroarch mgba true
  add_emu_core gba retroarch vbam false
  add_emu_core gba retroarch vba_next false
  add_emu_core gba retroarch beetle_gba false
  case ${DEVICE} in
    RK356*|RK3326|H700|S922X|SD865)
      add_emu_core gba retroarch gpsp false
    ;;
    RK3399|RK3588*)
      add_emu_core gba retroarch gpsp false
      add_emu_core gba nanoboyadvance nanoboyadvance-sa false
    ;;
    AMD64)
      add_emu_core gba nanoboyadvance nanoboyadvance-sa false
    ;;
  esac
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core gba mednafen gba false
    ;;
  esac
  add_es_system gba

  ### Nintendo GameBoy Advance Hacks
  add_emu_core gbah retroarch mgba true
  add_emu_core gbah retroarch vbam false
  add_emu_core gbah retroarch vba_next false
  add_emu_core gbah retroarch beetle_gba false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core gbah mednafen gba false
    ;;
  esac
  add_es_system gbah

  ### Nintendo GameBoy Color
  add_emu_core gbc retroarch gambatte true
  add_emu_core gbc retroarch sameboy false
  add_emu_core gbc retroarch gearboy false
  add_emu_core gbc retroarch tgbdual false
  add_emu_core gbc retroarch mgba false
  add_emu_core gbc retroarch vbam false
  add_emu_core gbc retroarch DoubleCherryGB false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core gbc mednafen gb false
    ;;
  esac
  add_es_system gbc

  ### Nintendo GameBoy Color Hacks
  add_emu_core gbch retroarch gambatte true
  add_emu_core gbch retroarch sameboy false
  add_emu_core gbch retroarch gearboy false
  add_emu_core gbch retroarch tgbdual false
  add_emu_core gbch retroarch mgba false
  add_emu_core gbch retroarch vbam false
  add_emu_core gbch retroarch DoubleCherryGB false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core gbch mednafen gb false
    ;;
  esac
  add_es_system gbch

  ### Nintendo GameCube
  case ${DEVICE} in
    AMD64|SD865|RK3399|S922X|RK3588)
      add_emu_core gamecube dolphin dolphin-sa-gc false
      add_emu_core gamecube dolphin dolphin-qt-gc true
      add_emu_core gamecube retroarch dolphin false
      install_script "Start Dolphin.sh"
      add_es_system gamecube
    ;;
    RK3566)
      add_emu_core gamecube dolphin dolphin-sa-gc true
      add_emu_core gamecube retroarch dolphin false
      add_es_system gamecube
    ;;
  esac

  ### Nintendo Wii
  case ${DEVICE} in
    AMD64|SD865|RK3399|S922X|RK3588)
      add_emu_core wii dolphin dolphin-sa-wii false
      add_emu_core wii dolphin dolphin-qt-wii true
      add_emu_core wii retroarch dolphin false
      add_es_system wii
    ;;
    RK3566)
      add_emu_core wii dolphin dolphin-sa-wii true
      add_emu_core wii retroarch dolphin false
      add_es_system wii
    ;;
  esac

  ### Nintendo Wii U
  case ${DEVICE} in
    AMD64)
      add_emu_core wiiu cemu cemu-sa true
      add_es_system wiiu
      install_script "Start CEMU.sh"
    ;;
  esac

  ### Sega GameGear
  add_emu_core gamegear retroarch gearsystem true
  add_emu_core gamegear retroarch genesis_plus_gx false
  add_emu_core gamegear retroarch picodrive false
  add_emu_core gamegear retroarch smsplus false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core gamegear mednafen gg false
    ;;
  esac
  add_es_system gamegear

  ### Sega GameGear Hacks
  add_emu_core ggh retroarch gearsystem true
  add_emu_core ggh retroarch genesis_plus_gx false
  add_emu_core ggh retroarch picodrive false
  add_emu_core ggh retroarch smsplus false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core ggh mednafen gg false
    ;;
  esac
  add_es_system ggh

  ### Intellivision
  add_emu_core intellivision retroarch freeintv true
  add_es_system intellivision

  ### Sun Microsystems J2ME
  add_emu_core j2me retroarch freej2me true
  add_es_system j2me

  ### Atari Jaguar
  add_emu_core atarijaguar retroarch virtualjaguar true
  add_es_system atarijaguar

  ### Atari Lynx
  add_emu_core atarilynx retroarch handy true
  add_emu_core atarilynx retroarch beetle_lynx false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core atarilynx mednafen lynx false
    ;;
  esac
  add_es_system atarilynx

  ### Infocom Z-Machine
  add_emu_core zmachine retroarch mojozork true
  add_es_system zmachine

  ### Arcade (MAME)
  add_emu_core mame retroarch mame2003_plus true
  add_emu_core mame retroarch mame2010 false
  add_emu_core mame retroarch mame2015 false
  add_emu_core mame retroarch mame false
  add_emu_core mame retroarch fbneo false
  add_emu_core mame retroarch fbalpha2012 false
  add_emu_core mame retroarch fbalpha2019 false
  add_es_system mame

  ### Sega MegaDrive
  add_emu_core megadrive-japan retroarch genesis_plus_gx true
  add_emu_core megadrive-japan retroarch genesis_plus_gx_wide false
  add_emu_core megadrive-japan retroarch picodrive
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core megadrive-japan mednafen md false
    ;;
  esac
  add_es_system megadrive-japan

  ### Sega Model 3
  case ${DEVICE} in
    RK3588|SD865)
      add_emu_core segamodel3 supermodel supermodel-sa true
      add_es_system segamodel3
    ;;
  esac

  ### Microsoft MS-DOS
  add_emu_core pc retroarch dosbox_pure
  add_emu_core pc retroarch dosbox_svn
  add_es_system pc

  ### Nintendo MSU-1
  add_emu_core snesmsu1 retroarch snes9x true
  add_emu_core snesmsu1 retroarch beetle_supafaust false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core snesmsu1 mednafen snes_faust false
    ;;
  esac
  add_es_system snesmsu1

  ### Microsoft MSX
  add_emu_core msx retroarch bluemsx true
  add_emu_core msx retroarch fmsx false
  add_es_system msx

  ### Microsoft MSX 2
  add_emu_core msx2 retroarch bluemsx true
  add_emu_core msx2 retroarch fmsx false
  add_es_system msx2

  ### Sega Naomi
  case ${DEVICE} in
    RK35*)
      add_emu_core naomi retroarch flycast2021 true
      add_emu_core naomi retroarch flycast false
      add_emu_core naomi flycast flycast-sa false
    ;;
    RK33*|H700)
      add_emu_core naomi retroarch flycast2021 false
      add_emu_core naomi flycast flycast-sa false
      add_emu_core naomi retroarch flycast true
    ;;
    S922X|SD865)
      add_emu_core naomi retroarch flycast2021 false
      add_emu_core naomi flycast flycast-sa true
      add_emu_core naomi retroarch flycast false
    ;;
    *)
      add_emu_core naomi retroarch flycast2021 false
      add_emu_core naomi retroarch flycast true
      add_emu_core naomi flycast flycast-sa false
    ;;
  esac
  add_es_system naomi

  ### SNK NeoGeo
  add_emu_core neogeo retroarch fbneo true
  add_emu_core neogeo retroarch mame2003_plus false
  add_emu_core neogeo retroarch fbalpha2012 false
  add_emu_core neogeo retroarch fbalpha2019 false
  add_emu_core neogeo retroarch mame2010 false
  add_emu_core neogeo retroarch mame2015 false
  add_emu_core neogeo retroarch mame false
  case ${TARGET_ARCH} in
    aarch64)
      add_emu_core neogeo retroarch geolith false
    ;;
  esac
  add_es_system neogeo

  ### SNK NeoCD
  add_emu_core neocd retroarch neocd true
  add_emu_core neocd retroarch fbneo false
  add_es_system neocd

  ### SNK NeoGeo Pocket
  add_emu_core ngp retroarch beetle_ngp true
  add_emu_core ngp retroarch race false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core ngp mednafen ngp false
    ;;
  esac
  add_es_system ngp

  ### SNK NeoGeo Pocket Color
  add_emu_core ngpc retroarch beetle_ngp true
  add_emu_core ngpc retroarch race false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core ngpc mednafen ngp false
    ;;
  esac
  add_es_system ngpc

  ### Nintendo 64
  add_emu_core n64 retroarch mupen64plus_next true
  if [ "${PREFER_GLES}" = "yes" ]; then
    # This core only has gles renderer
    add_emu_core n64 retroarch mupen64plus false
  fi
  add_emu_core n64 retroarch parallel_n64 false
  add_emu_core n64 mupen64plus mupen64plus-sa false
  add_es_system n64

  ### Nintendo DS
  case ${DEVICE} in
    AMD64)
      add_emu_core nds retroarch melonds true
      add_emu_core nds retroarch melondsds false
      add_emu_core nds retroarch desmume false
      add_emu_core nds melonds melonds-sa false
      install_script "Start MelonDS.sh"
    ;;
    RK3399|RK3*)
      add_emu_core nds drastic drastic-sa true
      add_emu_core nds retroarch melonds false
      add_emu_core nds retroarch melondsds false
      add_emu_core nds melonds melonds-sa false
      add_emu_core nds retroarch desmume false
      install_script "Start MelonDS.sh"
    ;;
    RK3326|H700)
      add_emu_core nds drastic drastic-sa true
      add_emu_core nds retroarch melonds false
      add_emu_core nds retroarch melondsds false
      add_emu_core nds retroarch desmume false
    ;;
    SD865)
      add_emu_core nds drastic drastic-sa false
      add_emu_core nds retroarch melonds false
      add_emu_core nds retroarch melondsds false
      add_emu_core nds melonds melonds-sa true
      add_emu_core nds retroarch desmume false
      install_script "Start MelonDS.sh"
    ;;
    *)
      add_emu_core nds drastic drastic-sa true
      add_emu_core nds retroarch melonds false
      add_emu_core nds retroarch melondsds false
    ;;
  esac
  add_es_system nds

  ### Nintendo NES
  add_emu_core nes retroarch nestopia true
  add_emu_core nes retroarch fceumm false
  add_emu_core nes retroarch quicknes false
  add_emu_core nes retroarch mesen false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core nes mednafen nes false
    ;;
  esac
  add_es_system nes

  ### Nintendo NES Hacks
  add_emu_core nesh retroarch nestopia true
  add_emu_core nesh retroarch fceumm false
  add_emu_core nesh retroarch quicknes false
  add_emu_core nesh retroarch mesen false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core nesh mednafen nesh false
    ;;
  esac
  add_es_system nesh

  ### Magnavox Odyssey
  add_emu_core odyssey2 retroarch o2em true
  add_es_system odyssey2

  ### OpenBOR
  add_emu_core openbor OpenBOR OpenBOR true
  add_es_system openbor

  ### NEC PC-8800
  add_emu_core pc-8800 retroarch quasi88 true
  add_es_system pc-8800

  ### NEC PC-9800
  add_emu_core pc-9800 retroarch np2kai true
  add_es_system pc-9800

  ### NEC PC Engine
  add_emu_core pcengine retroarch beetle_pce_fast true
  add_emu_core pcengine retroarch beetle_pce false
  add_emu_core pcengine retroarch beetle_supergrafx false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core pcengine mednafen pce false
      add_emu_core pcengine mednafen pce_fast false
    ;;
  esac
  add_es_system pcengine

  ### NEC PC Engine CD
  add_emu_core pcenginecd retroarch beetle_pce_fast true
  add_emu_core pcenginecd retroarch beetle_pce false
  add_emu_core pcenginecd retroarch beetle_supergrafx false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core pcenginecd mednafen pce false
      add_emu_core pcenginecd mednafen pce_fast false
    ;;
  esac
  add_es_system pcenginecd

  ### NEC PC-FX
  add_emu_core pcfx retroarch beetle_pcfx true
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core pcfx mednafen pcfx false
    ;;
  esac
  add_es_system pcfx

  ### Lexaloffle PICO-8
  add_emu_core pico-8 pico-8 pico8 true
  add_emu_core pico-8 retroarch fake08 false
  add_es_system pico-8

  ### Sony Playstation
  case ${DEVICE} in
    AMD64)
      add_emu_core psx retroarch beetle_psx true
      add_emu_core psx mednafen psx false
    ;;
    S922X)
      add_emu_core psx retroarch pcsx_rearmed true
      add_emu_core psx retroarch beetle_psx false
    ;;
    RK3588*)
      add_emu_core psx retroarch pcsx_rearmed true
      add_emu_core psx retroarch pcsx_rearmed32 false
      add_emu_core psx retroarch beetle_psx false
      add_emu_core psx mednafen psx false
    ;;
    RK3399|SD865)
      add_emu_core psx retroarch pcsx_rearmed32 true
      add_emu_core psx retroarch pcsx_rearmed false
      add_emu_core psx retroarch beetle_psx false
    ;;
    RK3566*)
      add_emu_core psx retroarch pcsx_rearmed32 true
      add_emu_core psx retroarch pcsx_rearmed false
    ;;
    RK3326|H700)
      add_emu_core psx retroarch pcsx_rearmed32 true
      add_emu_core psx retroarch pcsx_rearmed false
    ;;
  esac
  add_emu_core psx duckstation duckstation-sa false
  add_emu_core psx retroarch duckstation false
  add_emu_core psx retroarch swanstation false
  add_es_system psx
  install_script "Start Duckstation.sh"

  ### Sony Playstation 2
  case ${DEVICE} in
    AMD64)
      add_emu_core ps2 pcsx2 pcsx2-sa true
      add_emu_core ps2 retroarch pcsx2 false
      add_emu_core ps2 retroarch play false
      add_es_system ps2
      install_script "Start PCSX2.sh"
    ;;
    RK3588|S922X|RK3399|SD865)
      add_emu_core ps2 aethersx2 aethersx2-sa true
      add_es_system ps2
      install_script "Start AetherSX2.sh"
    ;;
  esac

  ### Sony Playstation 3
  case ${DEVICE} in
    AMD64|SD865)
      add_emu_core ps3 rpcs3 rpcs3-sa true
      add_es_system ps3
      install_script "Start RPCS3.sh"
    ;;
  esac

  ### Sony Playstation Portable
  add_emu_core psp ppsspp ppsspp-sa true
  add_es_system psp
  install_script "Start PPSSPP.sh"

  ### Sony Playstation Portable Minis
  add_emu_core pspminis ppsspp ppsspp-sa true
  add_emu_core pspminis retroarch ppsspp false
  add_es_system pspminis

  ### Sony Playstation Vita
  case ${DEVICE} in
    AMD64)
      add_emu_core psvita vita3k vita3k-sa true
      add_es_system psvita
    ;;
  esac

  ### Nintendo Pokemon Mini
  add_emu_core pokemini retroarch pokemini true
  add_es_system pokemini

  ### ScummVM
  add_emu_core scummvm scummvmsa scummvm true
  add_emu_core scummvm retroarch scummvm false
  add_es_system scummvm
  install_script "Start ScummVM.sh"

  ### Joseph Weisbecker CHIP-8
  add_emu_core chip-8 retroarch jaxe true
  add_es_system chip-8

  ### Sega 32X
  add_emu_core sega32x retroarch picodrive true
  add_es_system sega32x

  ### Sega CD
  add_emu_core segacd retroarch genesis_plus_gx true
  add_emu_core segacd retroarch picodrive false
  add_es_system segacd

  ### Sega Mega-CD
  add_emu_core megacd retroarch genesis_plus_gx true
  add_emu_core megacd retroarch picodrive false
  add_es_system megacd

  ### Sega Genesis
  add_emu_core genesis retroarch genesis_plus_gx true
  add_emu_core genesis retroarch genesis_plus_gx_wide false
  add_emu_core genesis retroarch picodrive false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core genesis mednafen md false
    ;;
  esac
  add_es_system genesis

  ### Sega Genesis Hacks
  add_emu_core genh retroarch genesis_plus_gx true
  add_emu_core genh retroarch genesis_plus_gx_wide false
  add_emu_core genh retroarch picodrive false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core genh mednafen md false
    ;;
  esac
  add_es_system genh

  ### Sega MasterSystem
  add_emu_core mastersystem retroarch gearsystem true
  add_emu_core mastersystem retroarch genesis_plus_gx false
  add_emu_core mastersystem retroarch picodrive false
  add_emu_core mastersystem retroarch smsplus false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core mastersystem mednafen sms false
    ;;
  esac
  add_es_system mastersystem

  ### Sega MegaDrive
  add_emu_core megadrive retroarch genesis_plus_gx true
  add_emu_core megadrive retroarch genesis_plus_gx_wide false
  add_emu_core megadrive retroarch picodrive false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core megadrive mednafen md false
    ;;
  esac
  add_es_system megadrive

  ### Sega MegaDrive Hacks
  add_emu_core megadriveh retroarch genesis_plus_gx true
  add_emu_core megadriveh retroarch genesis_plus_gx_wide false
  add_emu_core megadriveh retroarch picodrive false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core megadriveh mednafen md false
    ;;
  esac
  add_es_system megadriveh

  ### Welback Holdings Mega Duck
  add_emu_core megaduck retroarch sameduck true
  add_es_system megaduck

  ### Sega Saturn
  case ${TARGET_ARCH} in
    aarch64)
      add_emu_core saturn yabasanshiro yabasanshiro-sa true
      add_emu_core saturn retroarch yabasanshiro false
    ;;
    x86_64)
      add_emu_core saturn retroarch yabasanshiro true
    ;;
  esac
  case ${DEVICE} in
    AMD64|RK358*)
      add_emu_core saturn retroarch beetle_saturn false
      add_emu_core saturn mednafen ss false
  ;;
    S922X)
      add_emu_core saturn retroarch beetle_saturn false
  ;;
    SD865)
      add_emu_core saturn retroarch beetle_saturn false
      add_emu_core saturn retroarch kronos false
      add_emu_core saturn mednafen ss false
  ;;
  esac
  add_es_system saturn

  ### Sega ST-V
  case ${DEVICE} in
    RK3588*|AMD64)
      add_emu_core st-v mednafen ss true
    ;;
  esac
  add_es_system st-v

  ### Sega SG-1000
  add_emu_core sg-1000 retroarch gearsystem true
  add_emu_core sg-1000 retroarch genesis_plus_gx false
  add_emu_core sg-1000 retroarch picodrive false
  add_es_system sg-1000

  ### Sharp X1
  add_emu_core x1 retroarch x1 true
  add_es_system x1

  ### Microsoft XBox
  case ${DEVICE} in
    AMD64|SD865)
      add_emu_core xbox xemu xemu-sa true
      add_es_system xbox
      install_script "Start Xemu.sh"
    ;;
  esac

  ### Sinclair ZX Spectrum
  add_emu_core zxspectrum retroarch fuse
  add_es_system zxspectrum

  ### Sinclair ZX81
  add_emu_core zx81 retroarch 81 true
  add_es_system zx81

  ### NEC Super Grafx
  add_emu_core supergrafx retroarch beetle_supergrafx
  add_emu_core supergrafx retroarch beetle_pce
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core supergrafx mednafen pce false
      add_emu_core supergrafx mednafen pce_fast false
    ;;
  esac
  add_es_system supergrafx

  ### Nintendo SNES
  add_emu_core snes retroarch snes9x true
  add_emu_core snes retroarch snes9x2010 false
  add_emu_core snes retroarch snes9x2002 false
  add_emu_core snes retroarch snes9x2005_plus false
  add_emu_core snes retroarch beetle_supafaust false
  add_emu_core snes retroarch bsnes_mercury_accuracy false
  add_emu_core snes retroarch bsnes_mercury_balanced false
  add_emu_core snes retroarch bsnes_mercury_performance false
  case ${DEVICE} in
    AMD64|S922X|RK3399|RK3588|SD865)
      add_emu_core snes retroarch bsnes false
      add_emu_core snes retroarch bsnes_hd_beta false
	;;
  esac
  case ${DEVICE} in
    AMD64)
      add_emu_core snes mednafen snes_faust false
      add_emu_core snes mednafen snes false
    ;;
    RK33*|RK35*|H700)
      add_emu_core snes mednafen snes_faust false
	;;
  esac
  add_es_system snes

  ### Nintendo SNES Hacks
  add_emu_core snesh retroarch snes9x true
  add_emu_core snesh retroarch snes9x2010 false
  add_emu_core snesh retroarch snes9x2002 false
  add_emu_core snesh retroarch snes9x2005_plus false
  add_emu_core snesh retroarch beetle_supafaust false
  add_emu_core snes retroarch bsnes_mercury_accuracy false
  add_emu_core snes retroarch bsnes_mercury_balanced false
  add_emu_core snesh retroarch bsnes_mercury_performance false
  case ${DEVICE} in
    AMD64|S922X|RK3399|RK3588|SD865)
      add_emu_core snesh retroarch bsnes false
      add_emu_core snesh retroarch bsnes_hd_beta false
	;;
  esac
  case ${DEVICE} in
    AMD64)
      add_emu_core snesh mednafen snes false
      add_emu_core snesh mednafen snes_faust false
    ;;
    RK3*|H700)
      add_emu_core snesh mednafen snes_faust false
	;;
  esac
  add_es_system snesh

  ### Nintendo Super Famicom
  add_emu_core sfc retroarch snes9x true
  add_emu_core sfc retroarch snes9x2010 false
  add_emu_core sfc retroarch snes9x2002 false
  add_emu_core sfc retroarch snes9x2005_plus false
  add_emu_core sfc retroarch beetle_supafaust false
  add_emu_core snes retroarch bsnes_mercury_accuracy false
  add_emu_core snes retroarch bsnes_mercury_balanced false
  add_emu_core sfc retroarch bsnes_mercury_performance false
  case ${DEVICE} in
    AMD64|S922X|RK3399|RK358*|SD865)
      add_emu_core sfc retroarch bsnes false
      add_emu_core sfc retroarch bsnes_hd_beta false
	;;
  esac
  case ${DEVICE} in
    AMD64)
      add_emu_core sfc mednafen snes false
      add_emu_core sfc mednafen snes_faust false
    ;;
    RK3*|H700)
      add_emu_core snes mednafen snes_faust false
	;;
  esac
  add_es_system sfc

  ### Nintendo Stellaview
  add_emu_core satellaview retroarch snes9x true
  add_emu_core satellaview retroarch snes9x2010 false
  add_emu_core satellaview retroarch snes9x2002 false
  add_emu_core satellaview retroarch snes9x2005_plus false
  add_es_system satellaview

  ### Bandai SuFami Turbo
  add_emu_core sufami retroarch snes9x true
  add_es_system sufami

  ### Watara Supervision
  add_emu_core supervision retroarch potator true
  add_es_system supervision

  ### Nesbox TIC-80
  add_emu_core tic-80 retroarch tic80 true
  add_es_system tic-80

  ### Various WASM-4
  add_emu_core wasm4 retroarch wasm4 true
  add_es_system wasm4 
  
  ### NEC TurboGrafx 16
  add_emu_core tg16 retroarch beetle_pce_fast true
  add_emu_core tg16 retroarch beetle_pce false
  add_emu_core tg16 retroarch beetle_supergrafx false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core tg16 mednafen pce false
      add_emu_core tg16 mednafen pce_fast false
    ;;
  esac
  add_es_system tg16

  ### NEC TurboGrafx CD
  add_emu_core tg16cd retroarch beetle_pce_fast true
  add_emu_core tg16cd retroarch beetle_pce false
  add_emu_core tg16cd retroarch beetle_supergrafx false
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core tg16cd mednafen pce false
      add_emu_core tg16cd mednafen pce_fast false
    ;;
  esac
  add_es_system tg16cd

  ### Belogic Uzebox
  add_emu_core uzebox retroarch uzem true
  add_es_system uzebox

  ### Milton Bradley Vectrex
  add_emu_core vectrex retroarch vecx true
  add_es_system vectrex

  ### Philips - CDi
  add_emu_core cdi retroarch same_cdi true
  add_es_system cdi

  ### Philips Videopac
  add_emu_core videopac retroarch o2em true
  add_es_system videopac

  ### Nintendo VirtualBoy
  add_emu_core virtualboy retroarch beetle_vb true
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core virtualboy mednafen vb false
    ;;
  esac
  add_es_system virtualboy

  ### Bandai Wonderswan
  add_emu_core wonderswan retroarch beetle_wswan true
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core wonderswan mednafen wswan false
    ;;
  esac
  add_es_system wonderswan

  ### Bandai Wonderswan Color
  add_emu_core wonderswancolor retroarch beetle_wswan true
  case ${DEVICE} in
    RK3399|AMD64|RK3326|RK3588*|RK356*|H700)
      add_emu_core wonderswancolor mednafen wswan false
    ;;
  esac
  add_es_system wonderswancolor

  ### Sharp x68000
  add_emu_core x68000 retroarch px68k true
  add_es_system x68000

  ### EPOCH/YENO Super Cassette Vision
  add_emu_core scv retroarch emuscv true
  add_es_system scv

  ### Vircon32
  add_emu_core vircon32 retroarch vircon32 true
  add_es_system vircon32

  ### MO/TO Family
  add_emu_core moto retroarch theodore true
  add_es_system moto

  ### Palm OS
  add_emu_core palm retroarch mu true
  add_es_system palm

  ### PC Ports
  case ${TARGET_ARCH} in
    arm|aarch64)
      add_emu_core ports portmaster portmaster true
    ;;
  esac
  add_es_system ports

  ### Doom
  add_emu_core doom gzdoom gzdoom-sa true
  add_es_system doom

  ### Media Player
  add_emu_core mplayer mplayer mplayer true
  add_es_system mplayer

  ### Music Player
  add_emu_core music gmu gmu true
  add_es_system music

  ### Moonlight
  add_es_system moonlight

  ### Tools
  add_es_system tools

  ### Screenshots
  add_es_system imageviewer

  ### Create es_systems
  mk_es_systems

  ### Generate document
  mk_system_doc

  mkdir -p ${INSTALL}/usr/config/emulationstation
  cp -f ${ESTMP}/es_systems.cfg ${INSTALL}/usr/config/emulationstation

  if [ "${WINDOWMANAGER}" = "weston" ]
  then
    sed -i 's~%RUNCOMMAND%~weston-terminal --command="%ROM%"~g' ${INSTALL}/usr/config/emulationstation/es_systems.cfg
  elif [ "${WINDOWMANAGER}" = "swaywm-env" ]
  then
    sed -i 's~%RUNCOMMAND%~/usr/bin/foot %ROM%~g' ${INSTALL}/usr/config/emulationstation/es_systems.cfg
  else
    sed -i 's~%RUNCOMMAND%~/usr/bin/run %ROM%~g' ${INSTALL}/usr/config/emulationstation/es_systems.cfg
  fi

  ### Automount should handle this.
  cp -f ${ESTMP}/system-dirs.conf ${INSTALL}/usr/config

  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/scripts/mkcontroller ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/lib/autostart/common
  cp ${PKG_DIR}/autostart/* ${INSTALL}/usr/lib/autostart/common
  chmod 0755 ${INSTALL}/usr/lib/autostart/common/*
 
}

