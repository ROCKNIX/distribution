# Copyright, Linaro Ltd, 2023
# SPDX-License-Identifier: BSD-3-Clause
include(`audioreach/audioreach.m4') dnl
include(`util/pcm.m4') dnl
include(`audioreach/subgraph.m4') dnl
include(`audioreach/container.m4') dnl
include(`audioreach/module_log.m4') dnl
include(`audioreach/module_mfc.m4') dnl
include(`audioreach/module_i2s.m4') dnl
include(`util/mixer.m4') dnl
dnl
#
# SubGraph for Device Backend
#
#  _______________________________
# |   Sub Graph                   |
# | [LOG] -> [MFC] -> [DEVICE EP] |
# |_______________________________|
#
# Same as subgraph-device-i2s-playback.m4 plus an MFC ahead of the EP, so
# a backend running at a different bit width than the frontend gets its
# stream converted.

undefine(`LOG_MODULE_IID') dnl
undefine(`MFC_MODULE_IID') dnl
undefine(`I2S_MODULE_IID') dnl
undefine(`SG_INDEX') dnl
undefine(`CONTAINER_INDEX') dnl
undefine(`MOD_INDEX') dnl

undefine(`DEVICE_PERF_MODE') dnl
undefine(`DEVICE_DIRECTION') dnl
undefine(`CONT_SENARIO_ID') dnl
undefine(`CONT_CAP') dnl
undefine(`CONT_POSITION') dnl
undefine(`DEVICE_DOMAIN_ID') dnl
undefine(`CONT_STACK_SIZE') dnl

define(`DEVICE_PERF_MODE', APM_SG_PERF_MODE_LOW_LATENCY) dnl'
define(`DEVICE_DIRECTION', APM_SUB_GRAPH_DIRECTION_TX) dnl'
define(`CONT_SENARIO_ID', APM_SUB_GRAPH_SID_AUDIO_PLAYBACK) dnl'
define(`CONT_CAP', `ifelse(LPASS_VER_COMPAT, 110000, APM_CONTAINER_TYPE_ID_GC, APM_CONTAINER_CAP_ID_EP)') dnl'
define(`CONT_POSITION', APM_CONT_GRAPH_POS_STREAM)dnl'
define(`DEVICE_DOMAIN_ID', APM_PROC_DOMAIN_ID_ADSP) dnl'
define(`CONT_STACK_SIZE', 8192) dnl'
dnl
define(`LOG_MODULE_IID', MOD_IID_START) dnl
define(`MFC_MODULE_IID', eval(MOD_IID_START + 1)) dnl
define(`I2S_MODULE_IID', eval(MOD_IID_START + 2)) dnl
define(`SG_INDEX', 1) dnl
define(`CONTAINER_INDEX', 1) dnl
define(`MOD_INDEX', 1) dnl
dnl
dnl DEVICE_PLAYBACK_ROUTE(stream-index, dai-id)
define(`DEVICE_PLAYBACK_ROUTE',
`'
`SectionGraph."NAME_PREFIX.$1 $3 Graph" {'
`        index STR($1)'
`        lines ['
`                "NAME_PREFIX.logger$1, , $3 Audio Mixer"'
`                "NAME_PREFIX.mfc$1, , NAME_PREFIX.logger$1"'
`                "NAME_PREFIX.i2s_rx$1, , NAME_PREFIX.mfc$1"'
`                "$2 MI2S Playback, , NAME_PREFIX.i2s_rx$1"'
`        ]'
`}')


AR_SUBGRAPH(SG_INDEX, DEVICE_DAI_ID, SG_IID_START, DEVICE_PERF_MODE, DEVICE_DIRECTION, CONT_SENARIO_ID)
AR_CONTAINER(CONTAINER_INDEX, CONT_IID_START, CONT_CAP, CONT_STACK_SIZE, CONT_POSITION, DEVICE_DOMAIN_ID)

AR_MODULE_LOG(MOD_INDEX, SG_INDEX, CONTAINER_INDEX, 	LOG_MODULE_IID, 1, 1, 1, 2, 0x000019ab, 1, 0, MFC_MODULE_IID)
AR_MODULE_MFC(MOD_INDEX, SG_INDEX, CONTAINER_INDEX,	MFC_MODULE_IID, 1, 1, 1, 2, I2S_MODULE_IID)
AR_MODULE_I2S_RX(MOD_INDEX, SG_INDEX, CONTAINER_INDEX, 	I2S_MODULE_IID, 1, 0, 1, 0, DEVICE_INTF_TYPE, DEVICE_INTF_INDEX, DEVICE_DATA_FORMAT, DEVICE_SD_LINE_IDX, `DEVICE_NAME', NONE_IID)
DEVICE_PLAYBACK_ROUTE(MOD_INDEX, `DEVICE_NAME', `MIXER_PREFIX')
