# GENERIC_X64 canonical VM profile

`profile.json` is the source of truth for the guest-visible VM hardware used by
Linux/QEMU and macOS/UTM:

- Q35 + UEFI
- Haswell-v4 CPU (x86-64-v3 compatible), 4 vCPUs, 8 GiB RAM
- 16 GiB VirtIO disk with explicit 512-byte logical and physical sectors
- `virtio-gpu-gl-pci`, `virtio-net-pci`, Intel HDA, USB 3, and serial console

The host acceleration differs by necessity: Linux uses KVM when available,
while an x86_64 guest on Apple silicon uses QEMU TCG. The fixed CPU model and
devices keep the guest-visible environment equivalent.

Print or run the Linux QEMU command. `qemu-args` only prints: it touches no
socket, vars store or disk, so it is safe beside a running guest. `run` clears
a previous QEMU's monitor and serial sockets (a socket nobody listens on only
-- a symlink, any other file, or a socket a running guest still answers on is
refused, and nothing is cleared until every path has been checked) and makes
the guest's UEFI vars store from the firmware's template when it has none,
then starts QEMU. A vars
store whose size is not the template's was made for another firmware build
and is refused with its name: move it aside and the next start makes a new
one. Both refuse a disk under the profile's
16 GiB, and take the OVMF code image and vars template from one firmware
directory (`--ovmf-code` with `--ovmf-vars-template` names another pair):

```bash
projects/ROCKNIX/devices/GENERIC_X64/vm/generic-x64-vm \
  qemu-args target/ROCKNIX-GENERIC_X64.x86_64-<date>.qcow2

projects/ROCKNIX/devices/GENERIC_X64/vm/generic-x64-vm \
  run target/ROCKNIX-GENERIC_X64.x86_64-<date>.qcow2
```

The guest boots at QEMU's default mode, 1280x800. `--res WxH` sets the
display's preferred mode instead -- `xres=`/`yres=` on the virtio-gpu device,
for the desktop (`virtio-gpu-gl-pci`) and `--headless` (`virtio-gpu-pci`)
variants alike -- so a handheld panel's look is checked on the VM before a
device (fork #97):

```bash
projects/ROCKNIX/devices/GENERIC_X64/vm/generic-x64-vm \
  run --headless --res 640x480 target/ROCKNIX-GENERIC_X64.x86_64-<date>.qcow2
```

Generate the UTM bundle (a qcow2 that needs another file -- a backing image,
an external data file -- is refused: the bundle carries the one file; flatten
it with `qemu-img convert -O qcow2` first):

```bash
projects/ROCKNIX/devices/GENERIC_X64/vm/generic-x64-vm utm \
  target/ROCKNIX-GENERIC_X64.x86_64-<date>.qcow2 \
  --output target/ROCKNIX-GENERIC_X64.x86_64-<date>.utm.zip
```

Unzip the result on macOS and double-click `ROCKNIX-GENERIC_X64.utm`. UTM
creates its writable UEFI variable store on first launch.

## Networking

The UTM bundle uses **Emulated VLAN (NAT)** networking by default — it boots
everywhere, and SSH stays reachable through the host on 127.0.0.1:10022. For
full hardware parity (the VM joining your LAN with its own address), switch
the VM's network mode to **Bridged** in UTM's settings — one click, but macOS
vmnet bridging can fail on some Wi-Fi networks, which is why it is not the
default.

The Linux launcher uses QEMU user-mode networking: SSH stays on
127.0.0.1:10022 unless `--net lan` is given; `--net bridged` joins the LAN
directly if the host has a bridge configured.

### Cloud setup in the VM

Cloud setup runs `rclone config` over SSH. On real hardware the setup screen
shows `ssh root@<device-ip>`; behind the VM's NAT forward that address is
unreachable, so both launchers inject the forwarded SSH port via fw_cfg
(`opt/org.rocknix.cloud_ssh_port` — just the port, a space-free token,
because UTM splits QEMU arguments on whitespace), and the `095-cloud-ssh`
quirk assembles the command into `/storage/.config/cloud_setup_ssh`. The
forward always binds 127.0.0.1:10022, so the result is identical on every
host platform (Linux, macOS, Windows/WSL2 QEMU) and nothing needs detecting
or editing:

```
ssh -L 53682:localhost:53682 -p 10022 root@127.0.0.1
```

The `-L` tunnel carries rclone's OAuth sign-in page (guest port 53682) to the
browser of the machine running SSH, so the full `rclone config` auto flow
works from the host. A bundle generated for Bridged (and `--net bridged` on
Linux) omits the injection: the guest is on the LAN under its own address,
and the screen correctly shows it. The injection is fixed when the bundle is
made, though: a bundle switched to Bridged, or to a vmnet host network, in
UTM's settings keeps its two `-fw_cfg` entries under QEMU > Arguments, and
the screen keeps showing the loopback command, which does not reach the
guest there. Remove those two entries when you switch.

Manual fallback: write a full SSH command into
`/storage/.config/cloud_setup_ssh` in the guest (from the serial console).
It is kept across boots: `095-cloud-ssh` replaces or removes only the
command it wrote itself. Delete the file to go back to the automatic one.

### Troubleshooting: bridged mode hangs forever (UTM)

If switching the VM to Bridged makes it spin indefinitely, check the unified
log for `SWIFT TASK CONTINUATION MISUSE: start(launcher:interface:)` from UTM:
that means macOS's vmnet layer never finished creating the bridge and UTM is
awaiting it forever. Set the bridged interface explicitly (usually `en0`),
update UTM, and if it still hangs your Mac/network refuses vmnet bridging -
use the default Emulated VLAN mode.

Tester-confirmed workaround: in UTM's network settings, selecting the
**Default (private)** host network instead of a physical interface lets the
VM start reliably. Note that this is vmnet's host/shared network, not a true
LAN bridge - and UTM only applies port forwards (including the SSH forward
cloud setup depends on) in **Emulated VLAN** mode, the shipped default, not
in the vmnet host-network modes. Bridged confirmed broken on one test Mac on
both UTM 4.7.5 stable and the current beta.
