# SPDX-License-Identifier: BSD-3-Clause
# Mangmi Air X (SM6115) - I2S headphone + speaker playback + mic capture
include(`audioreach/audioreach.m4')
include(`audioreach/stream-subgraph.m4')
include(`audioreach/device-subgraph.m4')
include(`util/route.m4')
include(`util/mixer.m4')
include(`audioreach/tokens.m4')
#
# Stream SubGraphs
#
dnl Playback MultiMedia1 (Headphones)
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA1,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004001, 0x00004001, 0x00006001, `0')

dnl Playback MultiMedia2 (Speakers)
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA2,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004002, 0x00004002, 0x00006010, `0')

dnl Capture MultiMedia3 (Mic via ES8326)
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA3,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004003, 0x00004003, 0x00006020, `0')
#
# Device SubGraphs
#
dnl Headphone Playback via LPAIF_RXTX I2S -> QUAT MI2S SD3 -> ES8326
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-playback.m4, `Quaternary', QUATERNARY_MI2S_RX,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_RXTX, I2S_INTF_TYPE_PRIMARY, SD_LINE_IDX_I2S_SD3, DATA_FORMAT_FIXED_POINT,
	0x00004005, 0x00004005, 0x00006050, `QUAT_MI2S_RX')

dnl Speaker Playback via LPAIF_WSA I2S -> SEC MI2S SD0 -> AW88261
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-playback.m4, `Secondary', SECONDARY_MI2S_RX,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_WSA, I2S_INTF_TYPE_PRIMARY, SD_LINE_IDX_I2S_SD0, DATA_FORMAT_FIXED_POINT,
	0x00004007, 0x00004007, 0x00006070, `SEC_MI2S_RX')

dnl Mic Capture via ES8326 -> QUAT MI2S TX -> LPAIF_RXTX I2S
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-capture.m4, `Quaternary', QUATERNARY_MI2S_TX,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_RXTX, I2S_INTF_TYPE_PRIMARY, SD_LINE_IDX_I2S_SD3, DATA_FORMAT_FIXED_POINT,
	0x00004009, 0x00004009, 0x00006090, `QUAT_MI2S_TX')

dnl Headphone Mixer/Route
STREAM_DEVICE_PLAYBACK_MIXER(QUATERNARY_MI2S_RX, ``QUAT_MI2S_RX'', ``MultiMedia1'', ``MultiMedia2'')
STREAM_DEVICE_PLAYBACK_ROUTE(QUATERNARY_MI2S_RX, ``QUAT_MI2S_RX Audio Mixer'', ``MultiMedia1, stream0.logger1'', ``MultiMedia2, stream1.logger1'')

dnl Speaker Mixer/Route
STREAM_DEVICE_PLAYBACK_MIXER(SECONDARY_MI2S_RX, ``SEC_MI2S_RX'', ``MultiMedia1'', ``MultiMedia2'')
STREAM_DEVICE_PLAYBACK_ROUTE(SECONDARY_MI2S_RX, ``SEC_MI2S_RX Audio Mixer'', ``MultiMedia1, stream0.logger1'', ``MultiMedia2, stream1.logger1'')

dnl Mic Capture Mixer/Route
STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA3, ``QUAT_MI2S_TX'')
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA3, ``MultiMedia3 Mixer'', ``QUAT_MI2S_TX, device23.logger1'')
