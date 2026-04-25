#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

STEAM_MAIN_SCRIPT=${0}
STEAM_FLAVOR=arm64

source /etc/profile
set_kill set "-9 gamescope steam FEX"

# shellcheck source=start_steam.sh
. /usr/bin/start_steam.sh

steam_ensure_fex_config_template
steam_prepare_storage_and_vdf
steam_load_es_thunk_settings "$@"
steam_write_fex_config_json
steam_set_cpu_affinity
steam_debug_print

steam_arm64_binfmt_and_proton_prep
steam_read_sway_geometry
steam_scope_reexec_if_needed "$@"
steam_dual_screen_begin
steam_launch_bigpicture "$@"
steam_dual_screen_end
systemctl restart systemd-binfmt
