# SM8750 AudioReach topologies

The q6apm sound card gets its DSP graph from a binary topology, requested as
`qcom/sm8750/<card model>-tplg.bin`. The blobs themselves live in the
`extra-firmware` repo under `SM8750/qcom/sm8750/`, one per board:

| card model     | board                  |
|----------------|------------------------|
| `SM8750-KONKR` | KONKR Pocket FIT Elite |

Only the sources are kept here. The KONKR blob is also built into the kernel via
`CONFIG_EXTRA_FIRMWARE`, see the SM8750 block in
`projects/ROCKNIX/packages/linux/package.mk`; built-in firmware is searched
before the rootfs, so that copy wins.

Changing a blob means a commit in `extra-firmware` and a `PKG_VERSION` bump in
`projects/ROCKNIX/packages/linux-firmware/extra-firmware/package.mk`.

## Regenerating

Sources are the `.m4` files here, built with Linaro's macro library:

```sh
git clone https://git.codelinaro.org/linaro/qcomlt/audioreach-topology.git
cd audioreach-topology
m4 -I . <this dir>/SM8750-KONKR.m4 > SM8750-KONKR.conf
alsatplg -c SM8750-KONKR.conf -o SM8750-KONKR-tplg.bin
```

`alsatplg -d <blob> -o <conf>` decodes a blob back to text, so a regenerated
blob can be diffed against the shipped one before it goes in.

Two things to know when diffing against pre-2026-08 blobs: the current macros
emit tokens 204/205 (`MODULE_IN_PORTS`/`MODULE_OUT_PORTS`, deprecated and
ignored by the kernel), and the decoder drops per-element `index` values, so a
decode/recompile round trip regroups the blocks.

## Graph

| stream       | PCM     | backend             | UCM device  |
|--------------|---------|---------------------|-------------|
| MultiMedia1  | hw:0,0  | SECONDARY_MI2S_RX   | Speaker     |
| MultiMedia2  | hw:0,1  | RX_CODEC_DMA_RX_0   | Headphones  |
| MultiMedia3  | hw:0,2  | TX_CODEC_DMA_TX_3   | (capture)   |
| MultiMedia4  | hw:0,3  | DISPLAY_PORT_RX_0   | HDMI        |

The board DTS needs a matching `dp-dai-link` (`q6apmbedai DISPLAY_PORT_RX_0` ->
`&mdss_dp0`) for the DP backend to bind, and that link is what makes the
machine driver register the `DP0 Jack` control the UCM HDMI device keys off.
