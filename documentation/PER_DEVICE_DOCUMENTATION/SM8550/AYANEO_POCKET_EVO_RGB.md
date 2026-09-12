# AYANEO Pocket EVO RGB control

The Pocket EVO AR07 controller is exposed through one kernel serdev driver.
The driver is the only owner of the controller UART; applications must not
open `/dev/ttyHS0` directly.

EmulationStation remains Static-only. Its existing seven-value command is
unchanged:

```sh
analog_sticks_ledcontrol BRIGHTNESS RIGHT_R RIGHT_G RIGHT_B LEFT_R LEFT_G LEFT_B
```

The EVO helper represents each stick colour over its four zones and submits one
complete Static transaction. The driver coalesces that uniform layout into the
validated broadcast/left/right per-stick sequence, or one broadcast frame when
both sticks match. The four-value compatibility form applies one colour to both
rings.

## Sysfs controller ABI

Device-wide controls live on the parent serial device rather than on any one
quadrant LED. The Pocket EVO path is:

```sh
RGB=/sys/bus/serial/devices/serial1-0/rgb
```

Check the ABI and physical order before composing a layout:

```sh
cat "$RGB/abi_version"
cat "$RGB/zone_index"
```

ABI version 3 orders the zones as:

```text
left-zone-270 left-zone-0 left-zone-90 left-zone-180
right-zone-270 right-zone-0 right-zone-90 right-zone-180
```

`zone_layout` contains exactly 32 decimal byte values. Each listed zone owns
four consecutive values in `R G B brightness` order. One write is parsed and
transmitted as one serialized eight-zone transaction. For example, this makes
the complete left ring red at brightness 128 and the right ring blue at 255:

```sh
printf '%s\n' \
  '255 0 0 128 255 0 0 128 255 0 0 128 255 0 0 128 0 0 255 255 0 0 255 255 0 0 255 255 0 0 255 255' \
  >"$RGB/zone_layout"
```

The eight standard multicolor LED devices also expose `brightness`,
`multi_intensity`, `multi_index`, and `multi_max_intensity`. They are useful
for one-zone changes; `zone_layout` is the coherent whole-device interface.

## Colour calibration

Pocket EVO colour requests use a device-wide red-aware calibration at UART
serialization. The device-tuned default is green 15%, blue 20%:

```sh
cat "$RGB/calibration"
# 15 20
```

`calibration` accepts exactly two decimal percentages, green then blue, from
0 through 100. Red and brightness are unchanged. Green or blue is scaled only
when that channel and red are both nonzero, so pure green, pure blue, and cyan
remain raw. Zero suppresses that channel in mixed colours; positive results
retain a minimum value of one. `100 100` disables correction:

```sh
printf '%s\n' '15 20' >"$RGB/calibration"   # Pocket EVO default
printf '%s\n' '100 100' >"$RGB/calibration" # raw RGB
```

Changing calibration immediately reapplies the current Static, single-colour
Breath, or Reactive state when output is enabled. Calibration does not affect
RGB Breath or Rainbow, and changing it does not restart either effect. While
output is disabled the pair is cached and used on restore. Cached layouts and
effect arguments, and their readback, stay as the user's requested,
uncalibrated RGB values.

Userspace applications and scripts can persist the user's green/blue pair,
write it after detecting ABI 3, and use a uniform Static preview while their
calibration controls are open. That preview keeps each slider update on the
fast whole-ring path rather than the four-second mixed-quadrant path. A reset
action should write `15 20`; a raw/disabled action should write `100 100`. If
no userspace value is written, every boot starts with the hardware-tested
driver default.

## Effects

The device-wide `effect` interface accepts these complete lines:

```sh
printf '%s\n' static >"$RGB/effect"
printf '%s\n' 'breath 221 255 128 0' >"$RGB/effect"
printf '%s\n' 'rgb-breath 255' >"$RGB/effect"
printf '%s\n' rainbow >"$RGB/effect"
printf '%s\n' 'reactive 204 255 0 0 0 0 255' >"$RGB/effect"
```

- `static` reapplies the cached 32-value layout.
- `breath brightness r g b` renders a fixed-colour brightness curve in the
  driver.
- `rgb-breath brightness` renders the captured seven-colour palette in the
  driver.
- `rainbow` starts the controller MCU's autonomous four-zone Rainbow.
- `reactive brightness idle-r idle-g idle-b active-r active-g active-b`
  starts the controller MCU's stick-follow mode.

Read `available_effects` for the supported names and read `effect` to obtain a
line that can be written back later. Static LED writes always select Static;
they never select an advanced effect. To turn both rings off through the
normal ROCKNIX helper, use:

```sh
analog_sticks_ledcontrol 0 0 0 0
```

Writes require the normal privileged sysfs access used by ROCKNIX services.
The driver retains the hardware-qualified three-copy policy and 350 ms
inter-zone/final guards. A complete mixed eight-zone write blocks for about
4.0 seconds. The first frame is visible immediately; a sysfs write waits for
the complete serialized transaction.

### Temporary mixed-layout timing controls

The timing-qualification build exposes five bounded module parameters under:

```sh
TIMING=/sys/module/leds_ayaneo_pocket_evo/parameters
```

They affect only complete mixed-quadrant `zone_layout` writes. Uniform
per-stick Static, incremental LED-class writes, effects, UART timeouts, and
frame contents retain their validated timings.

| Parameter | Default | Range | Position in transaction |
| --- | ---: | ---: | --- |
| `mixed_init_copy_gap_ms` | 40 | 40–1000 | Between the three initializer copies |
| `mixed_post_init_ms` | 350 | 0–2500 | After the final initializer copy |
| `mixed_zone_copy_gap_ms` | 40 | 40–350 | Between each zone's three copies |
| `mixed_inter_zone_gap_ms` | 350 | 40–350 | After zones 1 through 7 |
| `mixed_final_guard_ms` | 350 | 0–350 | After zone 8 |

The total programmed delay is `2I + P + 16C + 7Z + F`, or 3.87 seconds at
the defaults. The driver snapshots all five values before starting a mixed
transaction, so parameter changes cannot alter a transaction in progress.
Only root can change them. Rebooting restores every default; a rejected value
returns `ERANGE` without changing the current setting.

Display the active values with:

```sh
for knob in mixed_init_copy_gap_ms mixed_post_init_ms \
            mixed_zone_copy_gap_ms mixed_inter_zone_gap_ms \
            mixed_final_guard_ms; do
  printf '%s=' "$knob"
  cat "$TIMING/$knob"
done
```

## Temporary output gate

`enabled` blanks and restores the rings without replacing their requested
effect or cached Static layout. This is different from writing an all-zero
`zone_layout`, which deliberately selects Static and caches that zero layout.

```sh
printf '%s\n' 0 >"$RGB/enabled"
cat "$RGB/effect"
cat "$RGB/zone_layout"
printf '%s\n' 1 >"$RGB/enabled"
```

While `enabled` is `0`, `effect`, `zone_layout`, and LED-class per-zone writes
update the desired cache without transmitting. Re-enabling restores the latest
Static, Breath, RGB Breath, Rainbow, or Reactive request. With no intervening
write, host-rendered effects resume from their paused step. MCU-rendered effects
retain their mode and arguments but restart the MCU's internal animation. Real
system suspend separately inhibits transport; device-wide writes then return
`EBUSY` until resume.

## Ownership and lifecycle

The EVO power/battery LED scripts no longer repaint the stick rings. Explicit
`rgb` selection and the EmulationStation analogue-stick setting select Static;
other userspace applications and scripts may select effects independently.

ROCKNIX currently uses fake suspend on SM8550: the display and processes are
quiesced without entering kernel power management. Its suspend/resume calls
use `enabled` to blank and restore the exact RGB state, unless an application
deliberately supplies a newer cached request while blanked. In particular,
fake resume does not run the Static-only analogue-stick helper even when the
saved ROCKNIX LED selection is `rgb`.

For a future real system suspend, the kernel driver independently blanks and
restores the exact RGB mode before and after the Qualcomm GENI UART's suspended
window. Kernel shutdown sends the validated off frame whether or not userspace
ran first.

Per-stick Static control and per-quadrant control share the coherent
`zone_layout` ABI, but not the same wire path. Four equal visible zones on each
ring are coalesced into the validated sequence: a target `0x1c` broadcast exits
segmented mode, then target `0x21` (left) and `0x20` (right) retain their own
whole-ring colours. If the two rings match, target `0x1c` alone is sufficient.
Only a genuinely mixed quadrant layout uses the slower direct-zone sequence.

The Pocket EVO Device Tree opts into the Xbox 360 controller-mode bootstrap
with `ayaneo,xbox360-mode`. The serial MCU driver sends that sequence during
probe and restores it after a real system resume. Devices using the generic
`ayaneo,serial-mcu` compatible without that property never receive the frame,
and no userspace process needs to become a second UART owner.

## Pocket EVO hardware validation

The transport, effects, timing profile, and calibration defaults used by ABI 3
were exercised on physical Pocket EVO hardware on 29 August 2026:

- EmulationStation applied matching and independent per-stick Static colours
  through the coalesced whole-ring path.
- An eight-colour layout produced the expected colours and alternating
  brightness across all eight physical zones.
- Repeated timing qualification reduced complete mixed layouts from 14.0
  seconds to about 4.0 seconds. The final 40/350/40/350/350 ms profile was
  reliable; 150 ms post-initializer and 250 ms inter-zone candidates each
  failed intermittently and were rejected.
- Side-by-side colour tests selected green 15% for orange reproduction and
  retained blue 20%; calibration affects mixed-red colours without changing
  pure green, pure blue, or cyan.
- Breath, RGB Breath, Rainbow, and Reactive all operated correctly. Reactive
  responded independently to the two physical sticks.
- Fake suspend blanked the rings, then restored host-rendered Breath,
  MCU-rendered Reactive, and an exact mixed eight-zone Static layout. Display
  wake retained its normal timing; the mixed layout rebuilt after wake.
- The post-test kernel log contained only the driver's registration message and
  no controller restore, effect, UART, or locking errors.
