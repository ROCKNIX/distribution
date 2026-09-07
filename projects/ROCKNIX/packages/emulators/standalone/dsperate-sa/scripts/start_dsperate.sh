#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

set_kill set "-9 dsperate"

CONF_DIR="/storage/.config/dsperate"
DSPERATE_INI="${CONF_DIR}/dsperate.ini"

if [ ! -d "${CONF_DIR}" ]; then
	mkdir -p "${CONF_DIR}"
fi

#Seed config
if [ ! -f "${DSPERATE_INI}" ]; then
	cp -f "/usr/config/dsperate/dsperate.ini" "${DSPERATE_INI}"
fi

if [ ! -d "/storage/roms/savestates/nds" ]; then
	mkdir -p "/storage/roms/savestates/nds"
fi

if [ ! -d "/storage/.cache/dsperate" ]; then
	mkdir -p "/storage/.cache/dsperate"
fi

#Ini key helper
set_ini_key() {
	if grep -q "^[[:space:]]*${1}[[:space:]]*=" "${DSPERATE_INI}"; then
		sed -i "s|^[[:space:]]*${1}[[:space:]]*=.*|${1} = ${2}|" "${DSPERATE_INI}"
	else
		sed -i "/^\[emu\]/a ${1} = ${2}" "${DSPERATE_INI}"
	fi
}

#Emulation Station Features
GAME=$(echo "${1}" | sed "s#^/.*/##")
PLATFORM=$(echo "${2}" | sed "s#^/.*/##")
SLAYOUT=$(get_setting screen_layout "${PLATFORM}" "${GAME}")
SCREEN=$(get_setting main_screen "${PLATFORM}" "${GAME}")
SMOOTH=$(get_setting smooth_scaling "${PLATFORM}" "${GAME}")
CHUNKY=$(get_setting chunky_pixels "${PLATFORM}" "${GAME}")
LCDGRID=$(get_setting lcd_grid "${PLATFORM}" "${GAME}")
VSYNC=$(get_setting vsync "${PLATFORM}" "${GAME}")
FRAMESKIP=$(get_setting frameskip "${PLATFORM}" "${GAME}")
SPEEDHACK=$(get_setting speed_hack "${PLATFORM}" "${GAME}")
AA=$(get_setting anti_aliasing "${PLATFORM}" "${GAME}")
ISCALE=$(get_setting integer_scale "${PLATFORM}" "${GAME}")
AUTOSAVE=$(get_setting autosave "${PLATFORM}" "${GAME}")

OPTS=("--fullscreen")

#Default layout
case "${SLAYOUT}" in
	vertical|horizontal|single|pip|dominant_v|dominant_h)
		OPTS+=("--layout" "${SLAYOUT}")
		;;
esac

#Primary/larger screen
case "${SCREEN}" in
	top|bottom)
		OPTS+=("--screen" "${SCREEN}")
		;;
esac

#Scaler options
if [ "${SMOOTH}" = "1" ]; then
	OPTS+=("--linear")
else
	#Chunky pixels (purposely low-res)
	[ "${CHUNKY}" = "1" ] && OPTS+=("--chunky" "mean")

	#LCD pixel grid
	case "${LCDGRID}" in
		0|"")
			;;
		*)
			OPTS+=("--lcd-grid" "${LCDGRID}")
			;;
	esac
fi

#Vsync
[ "${VSYNC}" = "0" ] && OPTS+=("--no-vsync")

#Frameskip
case "${FRAMESKIP}" in
	[0-9]*)
		OPTS+=("--frameskip" "${FRAMESKIP}")
		;;
esac

#Speed hacks
case "${SPEEDHACK}" in
	cpu_uc)
		OPTS+=("--cpu-uc")
		;;
	fast_load)
		OPTS+=("--fast-load")
		;;
	cpu_oc)
		OPTS+=("--fast-load" "--cpu-oc")
		;;
	timing_oc)
		OPTS+=("--fast-load" "--cpu-oc" "--timing-oc")
		;;
esac

#Forced integer scale
case "${ISCALE}" in
	under|over)
		OPTS+=("--integer-scale" "${ISCALE}")
		;;
esac

#Dual screen handling
[ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ] && OPTS+=("--dual-window")

#3D anti-aliasing
[ "${AA}" = "1" ] && OPTS+=("--aa")

#RetroAchievements
#Casual mode only: DSperate does not support hardcore (yet?).
if [ "$(get_setting "global.retroachievements")" = "1" ]; then
	RA_USER=$(get_setting "global.retroachievements.username")
	if [ -n "${RA_USER}" ]; then
		OPTS+=("--cheevos" "--cheevos-user" "${RA_USER}")
	fi
fi

#Auto Save/Load
case "${AUTOSAVE}" in
	[1-3])
		OPTS+=("--autoload")
		set_ini_key autosave true
		;;
	*)
		OPTS+=("--no-autoload")
		set_ini_key autosave false
		;;
esac

#7z compression handling
ROM="${1}"
if [[ "${ROM}" == *.7z ]]; then
	TEMP="/tmp/dsperate"
	rm -rf "${TEMP}"
	mkdir -p "${TEMP}"
	7z x -y -o"${TEMP}" "${ROM}"
	ROM=$(find "${TEMP}" -maxdepth 1 -type f -name "*.nds" | head -n 1)
fi

#Performance handling
CORES=$(get_setting "cores" "${PLATFORM}" "${GAME}")
unset EMUPERF
[ "${CORES}" = "little" ] && EMUPERF="${SLOW_CORES}"
[ "${CORES}" = "big" ] && EMUPERF="${FAST_CORES}"

${EMUPERF} /usr/bin/dsperate --config "${DSPERATE_INI}" "${OPTS[@]}" "${ROM}"
