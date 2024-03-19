<img src="https://raw.githubusercontent.com/JustEnoughLinuxOS/distribution/dev/distributions/JELOS/logos/rocknix-logo.png" width=192>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[![Latest Version](https://img.shields.io/github/release/JustEnoughLinuxOS/distribution.svg?color=5998FF&label=latest%20version&style=flat-square)](https://github.com/JustEnoughLinuxOS/distribution/releases/latest) [![Activity](https://img.shields.io/github/commit-activity/m/JustEnoughLinuxOS/distribution?color=5998FF&style=flat-square)](https://github.com/JustEnoughLinuxOS/distribution/commits) [![Pull Requests](https://img.shields.io/github/issues-pr-closed/JustEnoughLinuxOS/distribution?color=5998FF&style=flat-square)](https://github.com/JustEnoughLinuxOS/distribution/pulls) [![Discord Server](https://img.shields.io/discord/948029830325235753?color=5998FF&label=chat&style=flat-square)](https://discord.gg/seTxckZjJy)

---

Just Enough Linux Operating System (JELOS) is an immutable Linux distribution for handheld gaming devices developed by a small community of enthusiasts.  Our goal is to produce an operating system that has the features and capabilities that we need, and to have fun as we develop it.

## Features

* JELOS has a very active community of developers and users.
* Integrated cross-device local and remote network play.
* In-game touch support on supported devices.
* Fine grain control for battery life or performance.
* Includes support for playing Music and Video.
* Bluetooth audio and controller support.
* Support for HDMI audio and video out, and USB audio.
* Device to device and device to cloud sync with Syncthing and rclone.
* VPN support with Wireguard, Tailscale, and ZeroTier.
* Includes built-in support for scraping and retroachievements.

## Screenshots

<table>
  <tr>
    <td><img src="https://rocknix.org/_inc/images/screenshots/system-view.png"/></td>
    <td><img src="https://rocknix.org/_inc/images/screenshots/menu.png"/></td>
  </tr>
  <tr>
    <td><img src="https://rocknix.org/_inc/images/screenshots/gamelist-view-metadata-immersive.png"/></td>
    <td><img src="https://rocknix.org/_inc/images/screenshots/gamelist-view-no-metadata-immersive.png"/></td>
  </tr>
</table>

## Community

The JELOS community utilizes Discord for discussion, if you would like to join us please use this link: [https://discord.gg/seTxckZjJy](https://discord.gg/seTxckZjJy)

## Licenses

JELOS is a Linux distribution that is made up of many open-source components.  Components are provided under their respective licenses.  This distribution includes components licensed for non-commercial use only.

### JELOS Branding

JELOS branding and images are licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

You are free to:

- Share: copy and redistribute the material in any medium or format
- Adapt: remix, transform, and build upon the material

Under the following terms:

- Attribution: You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
- NonCommercial: You may not use the material for commercial purposes.
- ShareAlike: If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.

### JELOS Software

Copyright 2023 JELOS (https://github.com/JustEnoughLinuxOS)

Original software and scripts developed by the JELOS team are licensed under the terms of the [GNU GPL Version 2](https://choosealicense.com/licenses/gpl-2.0/).  The full license can be found in this project's licenses folder.

### Bundled Works
All other software is provided under each component's respective license.  These licenses can be found in the software sources or in this project's licenses folder.  Modifications to bundled software and scripts by the JELOS team are licensed under the terms of the software being modified.

## Documentation

### Contribute

* [Building JELOS](https://rocknix.org/contribute/build/)
* [Code of Conduct](https://rocknix.org/contribute/code-of-conduct/)
* [Contributing to JELOS](https://rocknix.org/contribute/)
* [Modifying JELOS](https://rocknix.org/contribute/modify/)
* [Adding Hardware Quirks](https://rocknix.org/contribute/quirks/)
* [Creating Packages](https://rocknix.org/contribute/packages/)
* [Pull Request Template](/PULL_REQUEST_TEMPLATE.md)

### Play

* [Installing JELOS](https://rocknix.org/play/install/)
* [Updating JELOS](https://rocknix.org/play/update/)
* [Controls](https://rocknix.org/play/controls/)
* [Netplay](https://rocknix.org/play/netplay/)
* [Configuring Moonlight](https://rocknix.org/systems/moonlight/)
* [Device Specific Documentation](/documentation/PER_DEVICE_DOCUMENTATION)

### Configure

* [Optimizations](https://rocknix.org/configure/optimizations/)
* [Shaders](https://rocknix.org/configure/shaders/)
* [Cloud Sync](https://rocknix.org/configure/cloud-sync/)
* [VPN](https://rocknix.org/configure/vpn/)

### Other

* [Frequently Asked Questions](https://rocknix.org/faqs/)
* [Donating to JELOS](https://rocknix.org/donations/)

## Device Support

JELOS supports a variety of ARM and Intel/AMD based devices.

| Manufacturer | Device | CPU / Architecture | Kernel | GL driver | Interface |
| -- | -- | -- | -- | -- | -- |
| Anbernic | [RG351P/M](https://rocknix.org/devices/anbernic/rg351pmv) | Rockchip RK3326 (ARM) | Mainline Linux | Panfrost | Weston + Emulation Station |
| Anbernic | [RG351v](https://rocknix.org/devices/anbernic/rg351pmv) | Rockchip RK3326 (ARM) | Mainline Linux | Panfrost | Weston + Emulation Station |
| Anbernic | [RG353P](https://rocknix.org/devices/anbernic/rg353pmvvs) | Rockchip RK3566 (ARM) | Rockchip BSP 4.19 | Mali | KMS/DRM + Emulation Station |
| Anbernic | [RG353M](https://rocknix.org/devices/anbernic/rg353pmvvs) | Rockchip RK3566 (ARM) | Rockchip BSP 4.19 | Mali | KMS/DRM + Emulation Station |
| Anbernic | [RG353V](https://rocknix.org/devices/anbernic/rg353pmvvs) | Rockchip RK3566 (ARM) | Rockchip BSP 4.19 | Mali | KMS/DRM + Emulation Station |
| Anbernic | [RG353VS](https://rocknix.org/devices/anbernic/rg353pmvvs) | Rockchip RK3566 (ARM) | Rockchip BSP 4.19 | Mali | KMS/DRM + Emulation Station |
| Anbernic | [RG503](https://rocknix.org/devices/anbernic/rg503) | Rockchip RK3566 (ARM) | Rockchip BSP 4.19 | Mali | KMS/DRM + Emulation Station |
| Anbernic | [RG552](https://rocknix.org/devices/anbernic/rg552) | Rockchip RK3399 (ARM) | Mainline Linux | Panfrost | Weston + Emulation Station |
| Anbernic | [Win600](https://rocknix.org/devices/anbernic/win600) | AMD Athlon Silver 3050e (x86_64) | Mainline Linux | Radeonsi | Weston + Emulation Station | 
| AOKZOE | [A1 Pro](https://rocknix.org/devices/aokzoe/a1-pro) | AMD 7840u (x86_64) | Mainline Linux | Radeonsi | Weston + Emulation Station |
| Atari | [VCS](https://rocknix.org/devices/atari/vcs) | AMD Ryzen R1606G (x86_64) | Mainline Linux | Radeonsi | Weston + Emulation Station |
| AYANEO | [Air / Air Pro](https://rocknix.org/devices/ayaneo/air) | Amd Ryzen 5 5560U / AMD Ryzen 7 5825U (x86_64) | Mainline Linux | Radeonsi | Weston + Emulation Station |
| AYANEO | [Air Plus](https://rocknix.org/devices/ayaneo/air-plus) | Amd Ryzen 7 6800U / (x86_64) | Mainline Linux | Radeonsi | Weston + Emulation Station |
| AYANEO | [AYANEO 2](https://rocknix.org/devices/ayaneo/ayaneo-2) | Amd Ryzen 7 6800U / (x86_64) | Mainline Linux | Radeonsi | Weston + Emulation Station |
| AYANEO | [AYANEO 2S](https://rocknix.org/devices/ayaneo/ayaneo-2) | Amd Ryzen 7 7840U / (x86_64) | Mainline Linux | Radeonsi | Weston + Emulation Station |
| Ayn | [Loki Zero](https://rocknix.org/devices/ayn/loki-zero) | AMD Athlon Silver 3050e (x86_64) | Mainline Linux | Radeonsi | Weston + Emulation Station |
| Ayn | [Loki Max](https://rocknix.org/devices/ayn/loki-max) | Amd Ryzen 7 6800U / (x86_64) | Mainline Linux | Radeonsi | Weston + Emulation Station |
| Gameforce | [ACE](https://rocknix.org/devices/gameforce/gameforce-ace/) | Rockchip RK3588S | Rockchip BSP | Panfrost | | Weston + Emulation Station |
| Game Console | [R33S](https://rocknix.org/devices/unbranded/game-console-r33s) | Rockchip RK3326 (ARM) | Mainline Linux | Panfrost | Weston + Emulation Station |
| Game Console | [R35S, R36S](https://rocknix.org/devices/unbranded/game-console-r35s-r36s) | Rockchip RK3326 (ARM) | Mainline Linux | Panfrost | Weston + Emulation Station |
| GPD | [Win 4](https://rocknix.org/devices/gpd/win4) | Amd Ryzen 7 6800U / (x86_64) | Mainline Linux | Radeonsi | Weston + Emulation Station |
| GPD | [Win Max 2 (2022)](https://rocknix.org/devices/gpd/win-max-2) | Amd Ryzen 7 6800U / (x86_64) | Mainline Linux| Radeonsi | Weston + Emulation Station |
| Hardkernel | [Odroid Go Advance](https://rocknix.org/devices/hardkernel/odroid-go-advance) | Rockchip RK3326 (ARM) | Mainline Linux | Panfrost | Weston + Emulation Station |
| Hardkernel | [Odroid Go Super](https://rocknix.org/devices/hardkernel/odroid-go-super) | Rockchip RK3326 (ARM) | Mainline Linux | Panfrost | Weston + Emulation Station |
| Hardkernel | [Odroid Go Ultra](https://rocknix.org/devices/hardkernel/odroid-go-ultra) | Amlogic S922X / Mali G52 M6 (ARMv8-A) | Mainline Linux | Mali | Weston + Emulation Station |
| Hardkernel | [Odroid N2/N2+/N2L](https://rocknix.org/devices/hardkernel/odroid-n2) | Amlogic S922X / Mali G52 M6 (ARMv8-A) | Mainline Linux | Mali | Weston + Emulation Station |
| Indiedroid | [Nova](https://rocknix.org/devices/indiedroid/nova) | Rockchip RK3588S / Mali G610 (ARMv8-A) | Rockchip 5.10 BSP Linux | Panfrost | Weston + Emulation Station |
| Orange Pi | [Orange Pi 5](https://rocknix.org/devices/orange-pi/orange-pi-5) | Rockchip RK3588S / Mali G610 (ARMv8-A) | Rockchip 5.10 BSP Linux | Panfrost | Weston + Emulation Station |
| Magicx | [XU10](https://rocknix.org/devices/magicx/xu10) | Rockchip RK3326 (ARM) | Mainline Linux | Panfrost | Weston + Emulation Station |
| Powkiddy | [RGB10](https://rocknix.org/devices/powkiddy/rgb10) | Rockchip RK3326 (ARM) | Mainline Linux | Panfrost | Weston + Emulation Station |
| Powkiddy | [RGB10 Max 3](https://rocknix.org/devices/powkiddy/rgb10-max-3) | Rockchip RK3566 (ARM) | Rockchip BSP 4.19 | Mali | KMS/DRM + Emulation Station |
| Powkiddy | [RGB10 Max 3 Pro](https://rocknix.org/devices/powkiddy/rgb10-max-3-pro) | Amlogic A311D / Mali G52 M4 (ARMv8-A) | Mainline Linux | Mali | Weston + Emulation Station |
| Powkiddy | [RGB30](https://rocknix.org/devices/powkiddy/rgb30) | Rockchip RK3566 (ARM) | Rockchip BSP 4.19 | Mali | KMS/DRM + Emulation Station |
| Powkiddy | [RK2023](https://rocknix.org/devices/powkiddy/rk2023) | Rockchip RK3566 (ARM) | Rockchip BSP 4.19 | Mali | KMS/DRM + Emulation Station |
| Powkiddy | [x55](https://rocknix.org/devices/powkiddy/x55) | Rockchip RK3566 (ARM) | Rockchip BSP 4.19 | Mali | KMS/DRM + Emulation Station |

> [!NOTE]
> While not technically supported, JELOS is also known to work well on a variety of generic x86_64 devices including gaming PCs, mini PCs, and laptop computers.

## Credits

Like any Linux distribution, this project is not the work of one person.  It is the work of many persons all over the world who have developed the open source bits without which this project could not exist.  Special thanks to CoreELEC, LibreELEC, and to developers and contributors across the open source community.
