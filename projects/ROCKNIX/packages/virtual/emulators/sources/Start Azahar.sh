
#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 azahar"

# Load gptokeyb support files
control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls

# Filesystem vars
IMMUTABLE_CONF_DIR="/usr/config/azahar"
CONF_DIR="/storage/.config/azahar"

# Make sure azahar config directory exists
[ ! -d ${CONF_DIR} ] && cp -r ${IMMUTABLE_CONF_DIR} /storage/.config
[ ! -d ${CONF_DIR}/log ] && mkdir -p ${CONF_DIR}/log

# Make sure gptokeyb mapping files exist
[ ! -f "${CONF_DIR}/azahar.gptk" ] && cp ${IMMUTABLE_CONF_DIR}/azahar.gptk ${CONF_DIR}
[ ! -f "${CONF_DIR}/azahar_mouse_addon.gptk" ] && cp ${IMMUTABLE_CONF_DIR}/azahar_mouse_addon.gptk ${CONF_DIR}

# Run Azahar Emulator fullscreen with gptokeyb mouse control enabled
sway_fullscreen "org.azahar_emu.Azahar" &
cat ${CONF_DIR}/azahar.gptk <(echo) ${CONF_DIR}/azahar_mouse_addon.gptk > /tmp/azahar.gptk
${GPTOKEYB} azahar -c /tmp/azahar.gptk & /usr/bin/azahar

kill -9 $(pidof gptokeyb)
