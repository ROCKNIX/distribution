#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

STEAM_MAIN_SCRIPT=${0}
STEAM_FLAVOR=native

source /etc/profile
set_kill set "gamescope steam"

# shellcheck source=start_steam.sh
. /usr/bin/start_steam.sh

steam_prepare_storage_and_vdf
steam_load_es_thunk_settings "$@"
steam_apply_lsfg_settings
steam_apply_fps_limit
steam_set_cpu_affinity
steam_debug_print

steam_read_sway_geometry
steam_setup_environment
steam_scope_reexec_if_needed "$@"
steam_dual_screen_begin
steam_launch_bigpicture "$@"
steam_dual_screen_end
