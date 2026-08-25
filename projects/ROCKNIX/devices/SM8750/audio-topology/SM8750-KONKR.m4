# SPDX-License-Identifier: BSD-3-Clause
# AudioReach topology source for the KONKR Pocket FIT Elite (SM8750).
#
# Build with the macro library from
# https://git.codelinaro.org/linaro/qcomlt/audioreach-topology:
#
#   m4 -I <audioreach-topology> SM8750-KONKR.m4 > SM8750-KONKR.conf
#   alsatplg -c SM8750-KONKR.conf -o SM8750-KONKR-tplg.bin
#
# Streams: MultiMedia1 = speakers, MultiMedia2 = headphones,
# MultiMedia3 = headset mic, MultiMedia4 = DisplayPort. PCM device numbers follow
# the stream index, so DisplayPort is hw:0,3 and that is what the UCM HDMI device
# opens.
#
# DisplayPort gets a stream of its own so the three outputs are three sinks in
# one card profile. Sharing the speaker PCM instead makes pipewire model them as
# alternative card profiles, and switching profiles tears down and rebuilds the
# sinks on signals that do not move in step with the cable, which strands the
# card on an unusable profile. Needs the DP driver to tolerate a prepare while
# the display is off (patch 0618).
#
# The Odin3 topology is the same with the I2S data line on SD0.
include(`audioreach/audioreach.m4')
include(`audioreach/stream-subgraph.m4')
include(`audioreach/device-subgraph.m4')
include(`util/route.m4')
include(`util/mixer.m4')
include(`audioreach/tokens.m4')
dnl Playback MultiMedia1
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA1,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004001, 0x00004001, 0x00006001, `110000')
dnl Playback MultiMedia2
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA2,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004002, 0x00004002, 0x00006010, `110000')
dnl Capture MultiMedia3
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA3,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004003, 0x00004003, 0x00006020, `110000')
dnl Playback MultiMedia4, feeds the DisplayPort backend only
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA4,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004004, 0x00004004, 0x00006030, `110000')
dnl Speaker amps: 2x AW88261 on SECONDARY MI2S. The populated amps are the
dnl stock quad-design's ch2/ch3, so the DSP has to drive data1 = SD1.
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-playback.m4, `Secondary', SECONDARY_MI2S_RX,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_LPAIF, I2S_INTF_TYPE_SECONDARY, SD_LINE_IDX_I2S_SD1, DATA_FORMAT_FIXED_POINT,
	0x00004005, 0x00004005, 0x00006050, `SECONDARY_MI2S_RX')
dnl WCD939x playback (headphones)
DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-playback.m4, `RX_CODEC_DMA_RX_0', RX_CODEC_DMA_RX_0,
	`S16_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_RXTX, CODEC_INTF_IDX_RX0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004007, 0x00004007, 0x00006070)
dnl WCD939x capture (headset mic)
DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-capture.m4, `TX_CODEC_DMA_TX_3', TX_CODEC_DMA_TX_3,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_RXTX, CODEC_INTF_IDX_TX3, 0, DATA_FORMAT_FIXED_POINT,
	0x00004009, 0x00004009, 0x00006090)
dnl DisplayPort over USB-C, fed from MultiMedia4. The DP sink module needs no
dnl interface index, the stream picks its DPTX from the dai id
dnl (DISPLAY_PORT_RX_0 = dai 104).
DEVICE_SG_ADD(audioreach/subgraph-device-display-port-playback.m4, `DISPLAY_PORT_RX_0', DISPLAY_PORT_RX_0,
	`S16_LE', 48000, 48000, 2, 2,
	0, 0, 0, DATA_FORMAT_FIXED_POINT,
	0x00004008, 0x00004008, 0x00006080, `DISPLAY_PORT_RX_0')

STREAM_DEVICE_PLAYBACK_MIXER(SECONDARY_MI2S_RX, ``SECONDARY_MI2S_RX'', ``MultiMedia1'', ``MultiMedia2'')
STREAM_DEVICE_PLAYBACK_MIXER(RX_CODEC_DMA_RX_0, ``RX_CODEC_DMA_RX_0'', ``MultiMedia1'', ``MultiMedia2'')
STREAM_DEVICE_PLAYBACK_MIXER(DISPLAY_PORT_RX_0, ``DISPLAY_PORT_RX_0'', ``MultiMedia4'')

STREAM_DEVICE_PLAYBACK_ROUTE(SECONDARY_MI2S_RX, ``SECONDARY_MI2S_RX Audio Mixer'', ``MultiMedia1, stream0.logger1'', ``MultiMedia2, stream1.logger1'')
STREAM_DEVICE_PLAYBACK_ROUTE(RX_CODEC_DMA_RX_0, ``RX_CODEC_DMA_RX_0 Audio Mixer'', ``MultiMedia1, stream0.logger1'', ``MultiMedia2, stream1.logger1'')
STREAM_DEVICE_PLAYBACK_ROUTE(DISPLAY_PORT_RX_0, ``DISPLAY_PORT_RX_0 Audio Mixer'', ``MultiMedia4, stream3.logger1'')

STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA3, ``TX_CODEC_DMA_TX_3'')
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA3, ``MultiMedia3 Mixer'', ``TX_CODEC_DMA_TX_3, device120.logger1'')
