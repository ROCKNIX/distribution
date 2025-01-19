#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

###
### System configuration variables
###

SYSTEM_CONFIG="/storage/.config/system/configs/system.cfg"
RETROARCH_PATH="/storage/.config/retroarch"
RETROARCH_CONFIG="${RETROARCH_PATH}/retroarch.cfg"
RETROARCH_TEMPLATE="/usr/config/retroarch/retroarch.cfg"

ROMS_DIR="/storage/roms"
SNAPSHOTS="${ROMS_DIR}/savestates"

TMP_CONFIG="/tmp/.retroarch.cfg"
LOG_DIR="/var/log"
LOG_FILE="exec.log"
LOCK_FILE="/tmp/.retroarch.lock"

###
### Variables parsed from the command line
###

PLATFORM=${1,,}
ROM="${2##*/}"
CORE=${3,,}


#Autosave
AUTOSAVE="$@"
AUTOSAVE="${AUTOSAVE#*-autosave=*}"
AUTOSAVE="${AUTOSAVE% --*}"

#Snapshot
SNAPSHOT="$@"
SNAPSHOT="${SNAPSHOT#*--snapshot=*}"

#Controllers
CONTROLLERS="$@"
CONTROLLERS="${CONTROLLERS#*--controllers=*}"

###
### Arrays containing various supported/non-supported attributes.
###

declare -a HAS_CHEEVOS=(    arcade
                            arduboy
                            atari2600
                            atari7800
                            atarilynx
                            cdi
                            colecovision
                            cps1
                            cps2
                            cps3
                            dreamcast
                            famicom
                            fbn
                            fds
                            gamegear
                            gb
                            gbh
                            gba
                            gbah
                            gbav
                            gbc
                            gbch
                            gbh
                            genesis
                            genh
                            ggh
                            intellivision
                            mastersystem
                            megacd
                            megadrive
                            megadrive-japan
                            msx
                            msx2
                            n64
                            nds
                            neogeo
                            neogeocd
                            nes
                            nesh
                            ngp
                            ngpc
                            odyssey2
                            opera
                            pcengine
                            pcenginecd
                            pcfx
                            pokemini
                            psp
                            psx
                            ps2
                            saturn
                            sega32x
                            segacd
                            sfc
                            sg-1000
                            snes
                            snesh
                            snesmsu1
                            supergrafx
                            supervision
                            tg16
                            tg16cd
                            vectrex
                            virtualboy
                            wonderswan
                            wonderswancolor
)

declare -a NO_REWIND=(  atomiswave
                        dreamcast
                        mame
                        n64
                        naomi
                        neogeocd
                        odyssey2
                        psp
                        pspminis
                        saturn
                        sega32x
                        zxspectrum
)

declare -a NO_RUNAHEAD=(    atomiswave
                            dreamcast
                            n64
                            naomi
                            neogeocd
                            psp
                            saturn
                            sega32x
)

declare -a NO_ANALOG=(  dreamcast
                        gc
                        n64
                        nds
                        ps2
                        psp
                        pspminis
                        psx
                        wii
                        wonderswan
                        wonderswancolor
)

declare -a IS_32BIT=(   gpsp
                        pcsx_rearmed
)

declare -a CORE_RATIOS=(    4/3
                            16/9
                            16/10
                            16/15
                            21/9
                            1/1
                            2/1
                            3/2
                            3/4
                            4/1
                            9/16
                            5/4
                            6/5
                            7/9
                            8/3
                            8/7
                            19/12
                            19/14
                            30/17
                            32/9
                            config
                            squarepixel
                            core
                            custom
                            full
)

declare -a LANG_CODES=( ["false"]="0"
                        ["En"]="1"
                        ["Fr"]="3"
                        ["Pt"]="49"
                        ["De"]="5"
                        ["El"]="30"
                        ["Es"]="2"
                        ["Cs"]="8"
                        ["Da"]="9"
                        ["Hr"]="11"
                        ["Hu"]="35"
                        ["It"]="4"
                        ["Ja"]="6"
                        ["Ko"]="12"
                        ["Nl"]="7"
                        ["Nn"]="46"
                        ["Po"]="48"
                        ["Ro"]="50"
                        ["Ru"]="51"
                        ["Sv"]="10"
                        ["Tr"]="59"
                        ["Zh"]="13"
)

###
### Fetch common settings
###

LOGGING=$(get_setting system.loglevel)
if [ -z "${LOGGING}" ]
then
  LOGGING="none"
fi

###
### Set up
###

### Create log directory if it doesn't exist
if [ ! -d "${LOG_DIR}" ]
then
    mkdir -p ${LOG_DIR}
fi

if [ -e "${LOCK_FILE}" ]
then
  rm -f "${LOCK_FILE}"
fi

### Clean up temp files
for FILE in ${TMP_CONFIG} ${TMP_CONFIG}.sed
do
  if [ -f "${FILE}" ]
  then
    rm -f "${FILE}"
  fi
done

###
### Core functions
###

function log() {
    if [ ${LOGGING} = "verbose" ]
    then
        echo "$(printf '%(%c)T\n' -1): setsettings: $*" >> ${LOG_DIR}/${LOG_FILE} 2>&1
    fi
}

function cleanup() {
    log "Work complete"
    sync
    exit
}

function game_setting() {
    if [ -n "${1}" ]
    then
        SETTING=$(get_setting "${1}" "${PLATFORM}" "${ROM}")
        log "Fetch \"${1}\" \"${PLATFORM}\" \"${ROM}\"] (${SETTING})"
        echo ${SETTING}
    fi
}

function clear_setting() {
      log "Remove setting [${1}]"
      if [ ! -f "${TMP_CONFIG}.sed" ]
      then
          echo -n 'sed -i "/^'${1}'/d;' >${TMP_CONFIG}.sed
      else
          echo -n ' /^'${1}'/d;' >>${TMP_CONFIG}.sed
      fi
}

function flush_settings() {
    echo -n '" '${RETROARCH_CONFIG}' >/dev/null 2>&1' >>${TMP_CONFIG}.sed
    chmod 0755 ${TMP_CONFIG}.sed
    ${TMP_CONFIG}.sed >/dev/null 2>&1 ||:
    rm -f ${TMP_CONFIG}.sed
}

function add_setting() {
    if [ ! "${1}" = "none" ]
    then
        local OS_SETTING="$(game_setting ${1})"
    fi
    local RETROARCH_KEY="${2}"
    local RETROARCH_VALUE="${3}"
    if [ -z "${RETROARCH_VALUE}" ]& \
       [ ! "${1}" = "none" ]
    then
        RETROARCH_VALUE="${OS_SETTING}"
    fi
    clear_setting "${RETROARCH_KEY}"
    echo "${RETROARCH_KEY} = \"${RETROARCH_VALUE}\"" >>${TMP_CONFIG}
    log "Added setting: ${RETROARCH_KEY} = \"${RETROARCH_VALUE}\""
}

function match() {
    local seek="${1}"
    shift
    local myarray=(${@})
    if [[ "${myarray[*]}" =~ ${seek} ]]
    then
        local MATCH="1"
    else
        local MATCH="0"
    fi
    log "Match: [${seek}] [${MATCH}] (${myarray[*]})"
    echo ${MATCH}
}

###
### Game data functions
###

### Configure retroarch paths
function set_retroarch_paths() {
  for RPATH in assets_directory cache_directory            \
               cheat_database_path content_database_path   \
               content_database_path joypad_autoconfig_dir \
               libretro_directory libretro_info_path       \
               overlay_directory video_shader_dir
  do
    clear_setting "${RPATH}"
  done
  flush_settings
  cat <<EOF >>${RETROARCH_CONFIG}
assets_directory = "/tmp/assets"
cache_directory = "/tmp/cache"
cheat_database_path = "/tmp/database/cht"
content_database_path = "/tmp/database/rdb"
joypad_autoconfig_dir = "/tmp/joypads"
libretro_directory = "/tmp/cores"
libretro_info_path = "/tmp/cores"
overlay_directory = "/tmp/overlays"
video_shader_dir = "/tmp/shaders"
EOF
}

### Configure retroarch hotkeys
function configure_hotkeys() {
    log "Configure hotkeys..."
    local MY_CONTROLLER=$(grep -b4 js0 /proc/bus/input/devices | awk 'BEGIN {FS="\""}; /Name/ {printf $2}')

    ### Remove any input settings retroarch may have added.
    sed -i '/input_player[0-9]/d' ${RETROARCH_CONFIG}

    if [ "$(get_setting system.autohotkeys)" == "1" ]
    then
        if [ -e "/tmp/joypads/${MY_CONTROLLER}.cfg" ]
        then
            cp /tmp/joypads/"${MY_CONTROLLER}.cfg" /tmp
            sed -i "s# = #=#g" /tmp/"${MY_CONTROLLER}.cfg"
            source /tmp/"${MY_CONTROLLER}.cfg"
            for HKEYSETTING in input_enable_hotkey_btn input_bind_hold            \
                               input_exit_emulator_btn input_fps_toggle_btn       \
                               input_menu_toggle_btn input_save_state_btn         \
                               input_load_state_btn input_toggle_fast_forward_btn \
                               input_toggle_fast_forward_axis input_rewind_axis   \
                               input_rewind_btn
            do
                clear_setting "${HKEYSETTING}"
            done
            flush_settings
            if [ -z ${input_enable_hotkey_btn+x} ]
            then
                echo 'input_enable_hotkey_btn = '\"${input_select_btn}\" >>${RETROARCH_CONFIG}
            else
                echo 'input_enable_hotkey_btn = '\"${input_enable_hotkey_btn}\" >>${RETROARCH_CONFIG}
            fi
            cat <<EOF >>${RETROARCH_CONFIG}
input_bind_hold = "${input_select_btn}"
input_exit_emulator_btn = "${input_start_btn}"
input_fps_toggle_btn = "${input_y_btn}"
input_menu_toggle_btn = "${input_x_btn}"
input_save_state_btn = "${input_r_btn}"
input_load_state_btn = "${input_l_btn}"
EOF
            if [ -n "${input_r2_btn}" ] && \
               [ -n "${input_l2_btn}" ]
            then
                cat <<EOF >>${RETROARCH_CONFIG}
input_toggle_fast_forward_axis = "nul"
input_toggle_fast_forward_btn = "${input_r2_btn}"
input_rewind_axis = "nul"
input_rewind_btn = "${input_l2_btn}"
EOF
            elif [ -n "${input_r2_axis}" ] && \
                 [ -n "${input_l2_axis}" ]
            then
                cat <<EOF >>${RETROARCH_CONFIG}
input_toggle_fast_forward_axis = "${input_r2_axis}"
input_toggle_fast_forward_btn = "nul"
input_rewind_axis = "${input_l2_axis}"
input_rewind_btn = "nul"
EOF
            fi
            rm -f /tmp/"${MY_CONTROLLER}.cfg"
        fi
    fi
}

function set_ra_menudriver() {
    add_setting "retroarch.menu_driver" "menu_driver"
    local MENU_DRIVER=$(game_setting retroarch.menu_driver)
    case ${MENU_DRIVER} in
        rgui)
            add_setting "none" "menu_linear_filter" "true"
        ;;
    esac
}

function set_fps() {
    add_setting "showFPS" "fps_show"
}

function set_config_save() {
    add_setting "config_save_on_exit" "false"
}

function set_cheevos() {
    local USE_CHEEVOS=$(game_setting "retroachievements")
    local CHECK_CHEEVOS="$(match "${PLATFORM}" "${HAS_CHEEVOS[@]}")"
    if [ "${USE_CHEEVOS}" = 1 ] && \
       [ "${CHECK_CHEEVOS}" = 1 ]
    then
        add_setting "none" "cheevos_enable" "true"
        add_setting "retroachievements.username" "cheevos_username"
        add_setting "retroachievements.password" "cheevos_password"
        add_setting "retroachievements.hardcore" "cheevos_hardcore_mode_enable"
        add_setting "retroachievements.leaderboards" "cheevos_leaderboards_enable"
        add_setting "retroachievements.verbose" "cheevos_verbose_enable"
        add_setting "retroachievements.screenshot" "cheevos_auto_screenshot"
        add_setting "retroachievements.richpresence" "cheevos_richpresence_enable"
        add_setting "retroachievements.challengeindicators" "cheevos_challenge_indicators"
        add_setting "retroachievements.testunofficial" "cheevos_test_unofficial"
        add_setting "retroachievements.badges" "cheevos_badges_enable"
        add_setting "retroachievements.active" "cheevos_start_active"
        local CHEEVOS_SOUND_ENABLE=$(game_setting "retroachievements.sound")
        if [ "${CHEEVOS_SOUND_ENABLE}" != "none" ]; then
            add_setting "none" "cheevos_unlock_sound_enable" "true"
            add_setting "retroachievements.sound" "cheevos_unlock_sound"
        else
            add_setting "none" "cheevos_unlock_sound_enable" "false"
        fi
    else
        add_setting "none" "cheevos_enable" "false"
    fi
}

function set_netplay() {
    USE_NETPLAY=$(game_setting "netplay")
    if [ "${USE_NETPLAY}" = 1 ]
    then
        add_setting "none" "savestate_auto_load" "false"
        add_setting "none" "savestate_auto_save" "false"
        add_setting "retroachievements.hardcore" "cheevos_hardcore_mode_enable" "false"
        add_setting "global.netplay.nickname" "netplay_nickname"
        add_setting "global.netplay.password" "netplay_password"
        add_setting "netplay_public_announce" "netplay_public_announce"
        local NETPLAY_MODE=$(game_setting "netplay.mode")
        local NETPLAY_PORT=$(game_setting "global.netplay.port")
        case ${NETPLAY_MODE} in
            host)
                add_setting "none" "netplay_mode" "false"
                add_setting "none" "netplay_client_swap_input" "false"
                add_setting "global.netplay.port" "netplay_ip_port" "${NETPLAY_PORT}"
                case ${CORE} in
                    gambatte)
                        log "Configuring gameboy link server."
                        if [ ! -d "${RETROARCH_PATH}/config/Gambatte" ]
                        then
                            mkdir -p "${RETROARCH_PATH}/config/Gambatte"
                        fi
                        local GAMBATTE_CONF="${RETROARCH_PATH}/config/Gambatte/Gambatte.opt"
                        ### Rework this to use add_setting and be configurable in ES.
                        sed -i '/gambatte_gb_link_mode/d; \
                                /gambatte_gb_link_network_port/d' ${GAMBATTE_CONF}
                        cat <<EOF >>${GAMBATTE_CONF}
gambatte_gb_link_mode = "Network Server"
gambatte_gb_link_network_port = "$(( ${NETPLAY_PORT} + 1 ))"
EOF
                    ;;
                    tgbdual)
                        log "Configuring tgbdual for network play"
                        if [ ! -d "${RETROARCH_PATH}/config/TGB Dual" ]
                        then
                            mkdir -p "${RETROARCH_PATH}/config/TGB Dual"
                        fi
                        local TGBDUAL_CONF="${RETROARCH_PATH}/config/TGB Dual/TGB Dual.opt"
                        sed -i '/tgbdual_gblink_enable/d; \
                                /tgbdual_single_screen_mp/d; \
                                /tgbdual_switch_screens/d; \
                                /tgbdual_audio_output/d' "${TGBDUAL_CONF}"
                        cat <<EOF >>"${TGBDUAL_CONF}"
tgbdual_gblink_enable = "enabled"
tgbdual_single_screen_mp = "player 1 only"
tgbdual_switch_screens = "normal"
tgbdual_audio_output = "Game Boy #1"
EOF
                        echo -n " --host"
                    ;;
                    genesis_plus_gx)
                        log "Configure genesis_plus_gx 4 way play."
                        add_setting "none" "input_libretro_device_p2" "1025"
                        echo -n " --host"
                    ;;

                    snes9x)
                        log "Configure snes9x multitap."
                        add_setting "none" "input_libretro_device_p2" "257"
                        echo -n " --host"
                    ;;
                    *)
                        echo -n " --host"
                    ;;
                esac
            ;;
            client)
                local NETPLAY_HOST_IP=$(get_setting global.netplay.host)
                add_setting "global.netplay.port" "${NETPLAY_PORT}"
                if [ ! -z "${NETPLAY_HOST_IP}" ]
                then
                    add_setting "none" "netplay_ip_address" "${NETPLAY_HOST_IP}"
                    case ${CORE} in
                        gambatte)
                            log "Configuring gameboy link client."
                            if [ ! -d "${RETROARCH_PATH}/config/Gambatte" ]
                            then
                                mkdir -p "${RETROARCH_PATH}/config/Gambatte"
                            fi
                            add_setting "none" "netplay_mode" "false"
                            add_setting "none" "netplay_client_swap_input" "false"
                            local GAMBATTE_CONF="${RETROARCH_PATH}/config/Gambatte/Gambatte.opt"
                            sed -i '/gambatte_gb_link_mode/d; \
                                    /gambatte_gb_link_network_port/d' ${GAMBATTE_CONF}
                            cat <<EOF >>${GAMBATTE_CONF}
gambatte_gb_link_mode = "Network Client"
gambatte_gb_link_network_port = "$(( ${NETPLAY_PORT} + 1 ))"
EOF

                            sed -i '/gambatte_gb_link_network_server_ip_/d'  ${GAMBATTE_CONF}

                            local IPARRAY=(${NETPLAY_HOST_IP//./ })
                            for ELEM in ${IPARRAY[*]}
                            do
                                ADDR="${ADDR}$(printf "%03d" "${ELEM}")"
                            done

                            local COUNT=1
                            for (( i=0; i<${#ADDR}; i++ ));
                            do
                                cat <<EOF >>${GAMBATTE_CONF}
gambatte_gb_link_network_server_ip_${COUNT} = "${ADDR:$i:1}"
EOF
                                COUNT=$(( ${COUNT} + 1 ))
                            done
                        ;;
                        tgbdual)
                            log "Configuring tgbdual for network play"
                            if [ ! -d "${RETROARCH_PATH}/config/TGB Dual" ]
                            then
                                mkdir -p "${RETROARCH_PATH}/config/TGB Dual"
                            fi
                            local TGBDUAL_CONF="${RETROARCH_PATH}/config/TGB Dual/TGB Dual.opt"
                            local PLAYER=$(get_setting wifi.adhoc.id)
                            if [ -z "${PLAYER}" ]
                            then
                                PLAYER=2
                            fi
                            sed -i '/tgbdual_gblink_enable/d; \
                                    /tgbdual_single_screen_mp/d; \
                                    /tgbdual_switch_screens/d; \
                                    /tgbdual_audio_output/d' "${TGBDUAL_CONF}"
                            cat <<EOF >"${TGBDUAL_CONF}"
tgbdual_gblink_enable = "enabled"
tgbdual_single_screen_mp = "player ${PLAYER} only"
tgbdual_switch_screens = "normal"
tgbdual_audio_output = "Game Boy #${PLAYER}"
EOF
                            add_setting "none" "netplay_mode" "true"
                            add_setting "none" "netplay_client_swap_input" "true"
                            echo -n " --connect ${NETPLAY_HOST_IP}"
                        ;;
                        *)
                            add_setting "none" "netplay_mode" "true"
                            add_setting "none" "netplay_client_swap_input" "true"
                            echo -n " --connect ${NETPLAY_HOST_IP}"
                        ;;
                    esac
                fi
            ;;
        esac
        local NETPLAY_RELAY=$(game_setting global.netplay.relay)
        if [ -n "${NETPLAY_RELAY}" ]
        then
          case $(NETPLAY_RELAY) in
              none|false|0)
                  add_setting "none" "netplay_use_mitm_server" "false"
              ;;
              *)
                  add_setting "none" "netplay_use_mitm_server" "true"
                  add_setting "none" "netplay_mitm_server" "${NETPLAY_RELAY}"
              ;; 
          esac
        else
            add_setting "none" "netplay_use_mitm_server" "false"
        fi
    else
        add_setting "none" "netplay" "false"
    fi
}

function set_translation() {
    local USE_AI_SERVICE="$(game_setting ai_service_enabled)"
    case ${USE_AI_SERVICE} in
        0|false|none)
            add_setting "none" "ai_service_enable" "false"
        ;;
        *)
            add_setting "none" "ai_service_enable" "true"
            local AI_LANG="$(game_setting ai_target_lang)"
            local AI_URL="$(game_setting ai_service_url)"
            case ${AI_URL} in
              0|false|none)
                add_setting "none" "ai_service_url" "http://ztranslate.net/service?api_key=BATOCERA&mode=Fast&output=png&target_lang=${AI_LANG}"
              ;;
              *)
                add_setting "none" "ai_service_url" "${AI_URL}&mode=Fast&output=png&target_lang=${AI_LANG}"
              ;;
            esac
        ;;
    esac
}

function set_aspectratio() {
    local ASPECT_RATIO="$(game_setting ratio)"
    case ${ASPECT_RATIO} in
      0|false|none)
        add_setting "none" "aspect_ratio_index" "22"
      ;;
      *)
        for AR in ${!CORE_RATIOS[@]}
        do
            if [ "${CORE_RATIOS[${AR}]}" = "${ASPECT_RATIO}" ]
            then
                add_setting "none" "aspect_ratio_index" "${AR}"
                break
            fi
        done
      ;;
    esac
#    add_setting "positionx" "custom_viewport_x"
#    add_setting "positiony" "custom_viewport_y"
#    add_setting "width" "custom_viewport_width"
#    add_setting "height" "custom_viewport_height"
    add_setting "rotation" "video_rotation"
}

function set_filtering() {
    add_setting "smooth" "video_smooth"
}

function set_integerscale() {
    add_setting "integerscale" "video_scale_integer"
    add_setting "integerscaleoverscale" "video_scale_integer_overscale"
}

function set_rgascale() {
    add_setting "rgascale" "video_ctx_scaling"
}

function set_shader() {
    local SHADER="$(game_setting shaderset)"
    case ${SHADER} in
        0|false|none)
            add_setting "none" "video_shader_enable" "false"
        ;;
        *)
            add_setting "none" "video_shader_enable" "true"
            add_setting "none" "video_shader" "${SHADER}"
            echo -n " --set-shader /tmp/shaders/${SHADER}"
        ;;
    esac
}

function set_filter() {
    local FILTER="$(game_setting videofilter)"
    case ${FILTER} in
        0|false|none)
            add_setting "none" "video_filter" ""
        ;;
        *)
            local FILTER_PATH="/usr/share/retroarch/filters"
            add_setting "none" "video_ctx_scaling" "false"
            local CHECK_BITNESS="$(match ${CORE} ${IS_32BIT[@]})"
            if [ "${CHECK_BITNESS}" = 1 ]
            then
                BITS="32"
            else
                BITS="64"
            fi
                add_setting "none" "video_filter" "${FILTER_PATH}/${BITS}bit/video/${FILTER}"
                add_setting "none" "video_filter_dir" "${FILTER_PATH}/${BITS}bit/video/"
                add_setting "none" "audio_filter_dir" "${FILTER_PATH}/${BITS}bit/audio"
        ;;
    esac
}

function set_overlay() {
    local OVERLAY="$(game_setting overlayset)"
    case ${OVERLAY} in
        0|false|none)
            add_setting "none" "input_overlay_enable" "false"
            add_setting "none" "input_overlay" ""
        ;;
        *)
            local OVERLAY_PATH="/storage/overlays"
            add_setting "none" "input_overlay_enable" "true"
            add_setting "none" "input_overlay" "${OVERLAY_PATH}/${OVERLAY}"
        ;;
    esac
}

function set_rewind() {
    local REWIND="$(game_setting rewind)"
    case ${REWIND} in
        1)
            case $(match ${PLATFORM} ${NO_REWIND[@]}) in
                0)
                    add_setting "none" "rewind_enable" "true"
                ;;
                *)
                    add_setting "none" "rewind_enable" "false"
                ;;
            esac
        ;;
        *)
            add_setting "none" "rewind_enable" "false"
        ;;
    esac
}

function set_savestates() {
    local SAVESTATES="$(game_setting incrementalsavestates)"
    local MAXINCREMENTALSAVES="$(game_setting maxincrementalsaves)"
    case ${SAVESTATES} in
        0|false|none)
            add_setting "none" "savestate_auto_index" "false"
        ;;
        *)
            add_setting "none" "savestate_auto_index" "true"
        ;;
    esac
    add_setting "none" "savestate_max_keep" "${MAXINCREMENTALSAVES}"
}

function set_autosave() {
    local SETAUTOSAVE=false

    # argument overrides user setting
    case ${AUTOSAVE} in
        0)
            SETAUTOSAVE=false
        ;;
        1)
            SETAUTOSAVE=true
        ;;
        *)
            local AUTOSAVE_SETTING="$(game_setting autosave)"
            case ${AUTOSAVE_SETTING} in
                [1-3])
                   SETAUTOSAVE=true
                ;;
            esac
        ;;
    esac
    
    add_setting "none" "savestate_directory" "${SNAPSHOTS}/${PLATFORM}"
    if [ ! -d "${SNAPSHOTS}/${PLATFORM}" ]
    then
        mkdir "${SNAPSHOTS}/${PLATFORM}"
    fi

    if [ ! -z "${SNAPSHOT}" ]
    then
        add_setting "none" "state_slot" "${SNAPSHOT}"
    fi

    add_setting "none" "savestate_auto_load" "${SETAUTOSAVE}"
    add_setting "none" "savestate_auto_save" "${SETAUTOSAVE}"
}

function set_runahead() {
    local RUNAHEAD="$(game_setting runahead)"
    local HAS_RUNAHEAD="$(match ${PLATFORM} ${NO_RUNAHEAD[@]})"
    case ${HAS_RUNAHEAD} in
        1)
            add_setting "none" "run_ahead_enabled" "false"
            add_setting "none" "run_ahead_frames" "0"
        ;;
        *)
            if [ "${RUNAHEAD}" -gt 0 ]
            then
                add_setting "none" "run_ahead_enabled" "true"
                add_setting "none" "run_ahead_frames" "${RUNAHEAD}"
                add_setting "secondinstance" "run_ahead_secondary_instance"
            else
                add_setting "none" "run_ahead_enabled" "false"
                add_setting "none" "run_ahead_frames" "0"
            fi
        ;;
    esac
}

function set_audiolatency() {
    add_setting "audiolatency" "audio_latency"
}

function set_analogsupport() {
    local HAS_ANALOG="$(match ${PLATFORM} ${NO_ANALOG[@]})"
    case ${HAS_ANALOG} in
        1)
            add_setting "none" "input_player1_analog_dpad_mode" "0"
        ;;
        *)
            add_setting "analogue" "input_player1_analog_dpad_mode" "1"
        ;;
    esac
}

function set_tatemode() {
    log "Setup tate mode..."
    if [ "${CORE}" = "mame2003_plus" ]
    then
        local TATEMODE="$(game_setting tatemode)"
        local MAME2003DIR="${RETROARCH_PATH}/config/MAME 2003-Plus"
        local MAME2003REMAPDIR="/storage/remappings/MAME 2003-Plus"
        if [ ! -d "${MAME2003DIR}" ]
        then
            mkdir -p "${MAME2003DIR}"
        fi
        if [ ! -d "${MAME2003REMAPDIR}" ]
        then
            mkdir -p "${MAME2003REMAPDIR}"
        fi
        case ${TATEMODE} in
            1|true)
                cp "/usr/config/retroarch/TATE-MAME 2003-Plus.rmp" "${MAME2003REMAPDIR}/MAME 2003-Plus.rmp"
                if [ "$(grep mame2003-plus_tate_mode "${MAME2003DIR}/MAME 2003-Plus.opt" > /dev/null 2>&1)" ]
                then
                    sed -i 's#mame2003-plus_tate_mode.*$#mame2003-plus_tate_mode = "enabled"#' "${MAME2003DIR}/MAME 2003-Plus.opt" 2>/dev/null
                else
                    echo 'mame2003-plus_tate_mode = "enabled"' > "${MAME2003DIR}/MAME 2003-Plus.opt"
                fi
            ;;
            *)
                if [ -e "${MAME2003DIR}/MAME 2003-Plus.opt" ]
                then
                    sed -i 's#mame2003-plus_tate_mode.*$#mame2003-plus_tate_mode = "disabled"#' "${MAME2003DIR}/MAME 2003-Plus.opt" 2>/dev/null
                fi
                if [ -e "${MAME2003REMAPDIR}/MAME 2003-Plus.rmp" ]
                then
                    rm -f "${MAME2003REMAPDIR}/MAME 2003-Plus.rmp"
                fi
            ;;
        esac
    fi
}

function set_n64opts() {
    log "Set up N64..."
    if [ "${CORE}" = "parallel_n64" ]
    then
        local PARALLELN64DIR="${RETROARCH_PATH}/config/ParaLLEl N64"
        if [ ! -d "${PARALLELN64DIR}" ]
        then
            mkdir -p "${PARALLELN64DIR}"
        fi

        if [ ! -f "${PARALLELN64DIR}/ParaLLEl N64.opt" ]
        then
            cp "/usr/config/retroarch/ParaLLEl N64.opt" "${PARALLELN64DIR}/ParaLLEl N64.opt"
        fi
        local VIDEO_CORE="$(game_setting parallel_n64_video_core)"
        sed -i '/parallel-n64-gfxplugin = /c\parallel-n64-gfxplugin = "'${VIDEO_CORE}'"' "${PARALLELN64DIR}/ParaLLEl N64.opt"
        local SCREENSIZE="$(game_setting parallel_n64_internal_resolution)"
        sed -i '/parallel-n64-screensize = /c\parallel-n64-screensize = "'${SCREENSIZE}'"' "${PARALLELN64DIR}/ParaLLEl N64.opt"
        local GAMESPEED="$(game_setting parallel_n64_gamespeed)"
        sed -i '/parallel-n64-framerate = /c\parallel-n64-framerate = "'${GAMESPEED}'"' "${PARALLELN64DIR}/ParaLLEl N64.opt"
        local ACCURACY="$(game_setting parallel_n64_gfx_accuracy)"
        sed -i '/parallel-n64-gfxplugin-accuracy = /c\parallel-n64-gfxplugin-accuracy = "'${ACCURACY}'"' "${PARALLELN64DIR}/ParaLLEl N64.opt"
        local CONTROLLERPAK="$(game_setting parallel_n64_controller_pak)"
        sed -i '/parallel-n64-pak1 = /c\parallel-n64-pak1 = "'${CONTROLLERPAK}'"' "${PARALLELN64DIR}/ParaLLEl N64.opt"
    fi
}

function set_saturnopts() {
    log "Set up Saturn..."
    if [ "${CORE}" = "kronos" ]
    then
        log "Set up Kronos..."
        local KRONOSDIR="${RETROARCH_PATH}/Kronos/config/Kronos"
        if [ ! -d "${KRONOSDIR}" ]
        then
            mkdir -p "${KRONOSDIR}"
        fi

        if [ ! -f "${KRONOSDIR}/Kronos.opt" ]
        then
            cp "/usr/config/retroarch/Kronos.opt" "${KRONOSDIR}/Kronos.opt"
        fi
        local KRONOSOPT="${KRONOSDIR}/Kronos.opt"
        local HLE_BIOS="$(game_setting force_hle_bios)"
        sed -i '/kronos_force_hle_bios = /c\kronos_force_hle_bios = "'${HLE_BIOS}'"' "${KRONOSOPT}"
        local ADDON_CART="$(game_setting addon_cartridge)"
        sed -i '/kronos_addon_cartridge = /c\kronos_addon_cartridge = "'${ADDON_CART}'"' "${KRONOSOPT}"
        local TESSELATION="$(game_setting tesselation)"
        sed -i '/kronos_polygon_mode = /c\kronos_polygon_mode = "'${TESSELATION}'"' "${KRONOSOPT}"
        local RESOLUTION="$(game_setting resolution)"
        sed -i '/kronos_resolution_mode = /c\kronos_resolution_mode = "'${RESOLUTION}'"' "${KRONOSOPT}"
        local COMPUTE_SHADER="$(game_setting compute_shader)"
        sed -i '/kronos_use_cs = /c\kronos_use_cs = "'${COMPUTE_SHADER}'"' "${KRONOSOPT}"
        local TRANSPARENCY="$(game_setting transparency)"
        sed -i '/kronos_mesh_mode = /c\kronos_mesh_mode = "'${TRANSPARENCY}'"' "${KRONOSOPT}"
    fi
}

function set_snesopts() {
    log "Set up SNES..."
    if [ "${CORE}" = "beetle_supafaust" ]
    then
        log "Set up beetle_supafaust"
        local FAUSTDIR="${RETROARCH_PATH}/config/Supafaust"
        if [ ! -d "${FAUSTDIR}" ]
        then
            mkdir -p "${FAUSTDIR}"
        fi
        if [ ! -f "${FAUSTDIR}/Supafaust.opt" ]
        then
            cp "/usr/config/retroarch/Supafaust.opt" "${FAUSTDIR}/Supafaust.opt"
        fi
    fi
}

function set_dreamcastopts() {
    log "Set up Dreamcast..."
    if [ "${CORE}" = "flycast" ]
    then
        local FLYCASTDIR="${RETROARCH_PATH}/config/Flycast"
        if [ ! -d "${FLYCASTDIR}" ]
        then
            mkdir -p "${FLYCASTDIR}"
        fi

        if [ ! -f "${FLYCASTDIR}/Flycast.opt" ]
        then
            cp "/usr/config/retroarch/Flycast.opt" "${FLYCASTDIR}/Flycast.opt"
        fi
        local FRAME_SKIP="$(game_setting frame_skip)"
        sed -i '/flycast_auto_skip_frame = /c\flycast_auto_skip_frame = "'${FRAME_SKIP}'"' "${FLYCASTDIR}/Flycast.opt"
    fi
}

function set_atari() {
    log "Set up Atari (FIXME)..."
    if [ "${CORE}" = "atari800" ]
    then
        ATARICONF="/storage/.config/system/configs/atari800.cfg"
        ATARI800CONF="${RETROARCH_PATH}/config/Atari800/Atari800.opt"
        if [ ! -f "$ATARI800CONF" ]
        then
            touch "$ATARI800CONF"
        fi
        sed -i "/RAM_SIZE=/d" ${ATARICONF}
        sed -i "/STEREO_POKEY=/d" ${ATARICONF}
        sed -i "/BUILTIN_BASIC=/d" ${ATARICONF}
        sed -i "/atari800_system =/d" ${ATARI800CONF}

        if [ "${PLATFORM}" == "atari5200" ]; then
            add_setting "none" "atari800_system" "5200"
            echo "atari800_system = \"5200\"" >> ${ATARI800CONF}
            echo "RAM_SIZE=16" >> ${ATARICONF}
            echo "STEREO_POKEY=0" >> ${ATARICONF}
            echo "BUILTIN_BASIC=0" >> ${ATARICONF}
        else
            add_setting "none" "atari800_system" "800XL (64K)"
            echo "atari800_system = \"800XL (64K)\"" >> ${ATARI800CONF}
            echo "RAM_SIZE=64" >> ${ATARICONF}
            echo "STEREO_POKEY=1" >> ${ATARICONF}
            echo "BUILTIN_BASIC=1" >> ${ATARICONF}
        fi
	flush_settings
    fi
}

function set_gambatte() {
    log "Set up Gambatte..."
    if [ "${CORE}" = "gambatte" ]
    then
        GAMBATTECONF="${RETROARCH_PATH}/config/Gambatte/Gambatte.opt"
        if [ ! -f "GAMBATTECONF" ]
        then
            echo 'gambatte_gbc_color_correction = "disabled"' > ${GAMBATTECONF}
        else
            sed -i "/gambatte_gb_colorization =/d" ${GAMBATTECONF}
            sed -i "/gambatte_gb_internal_palette =/d" ${GAMBATTECONF}
        fi
        local COLORIZATION=$(game_setting renderer.colorization)
        local TWB1_COLORIZATION=$(game_setting renderer.twb1_colorization)
        local TWB2_COLORIZATION=$(game_setting renderer.twb2_colorization)
        local TWB3_COLORIZATION=$(game_setting renderer.twb3_colorization)
        local PIXELSHIFT1_COLORIZATION=$(game_setting renderer.pixelshift1_colorization)

	if [ -n "${COLORIZATION}" ]
        then
            case ${COLORIZATION} in
                0|false|none)
                    echo 'gambatte_gb_colorization = "disabled"' >> ${GAMBATTECONF}
                ;;
                "Best Guess")
                    echo 'gambatte_gb_colorization = "auto"' >> ${GAMBATTECONF}
                ;;
                GBC|SGB)
                    echo 'gambatte_gb_colorization = "'${COLORIZATION}'"' >> ${GAMBATTECONF}
                ;;
                *)
                    echo 'gambatte_gb_colorization = "internal"' >> ${GAMBATTECONF}
                    echo 'gambatte_gb_internal_palette = "'${COLORIZATION}'"' >> ${GAMBATTECONF}
                    echo 'gambatte_gb_palette_twb64_1 = "'${TWB1_COLORIZATION}'"' >> ${GAMBATTECONF}
                    echo 'gambatte_gb_palette_twb64_2 = "'${TWB2_COLORIZATION}'"' >> ${GAMBATTECONF}
                    echo 'gambatte_gb_palette_twb64_3 = "'${TWB3_COLORIZATION}'"' >> ${GAMBATTECONF}
		            echo 'gambatte_gb_palette_pixelshift_1 = "'${PIXELSHIFT1_COLORIZATION}'"' >> ${GAMBATTECONF}
                ;;
            esac
        fi
    fi
}

function setup_controllers() {
    for i in $(seq 1 1 5)
    do
        log "Controller setup (${i})"
        if [[ "$CONTROLLERS" == *p${i}* ]]
        then
            PINDEX="${CONTROLLERS#*-p${i}index }"
            PINDEX="${PINDEX%% -p${i}guid*}"
            log "Set up controller ($i) (${PINDEX})"
            add_setting "none" "input_player${i}_joypad_index" "${PINDEX}"
            case ${PLATFORM} in
                atari5200)
                    add_setting "none" "input_libretro_device_p${i}" "513"
                ;;
            esac
        fi
    done
    flush_settings
}

###
### Execute functions
###

###
### Functions that must be run without parallelization.
###

set_retroarch_paths
setup_controllers
configure_hotkeys

###
### Game specific functions
###

set_atari &
set_gambatte &

wait
flush_settings

###
### Functions that can execute in parallel.
###

set_ra_menudriver &
set_config_save &
set_fps &
set_cheevos &
set_translation &
set_aspectratio &
set_filtering &
set_integerscale &
set_rgascale &
set_shader &
set_filter &
set_overlay &
set_rewind &
set_savestates &
set_autosave &
set_netplay &
set_runahead &
set_audiolatency &
set_analogsupport &
set_tatemode &
set_n64opts &
set_saturnopts &
set_snesopts &
set_dreamcastopts &

### Sed operations are expensive, so they are staged and executed as
### a single process when all forks complete.
wait
flush_settings

cleanup
