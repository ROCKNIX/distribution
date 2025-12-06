&nbsp;&nbsp;<img src="https://raw.githubusercontent.com/ROCKNIX/distribution/next/distributions/ROCKNIX/logos/rocknix-logo.png" width=192>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[![Latest Version](https://img.shields.io/github/release/ROCKNIX/distribution.svg?color=5998FF&label=latest%20version&style=flat-square)](https://github.com/ROCKNIX/distribution/releases/latest) [![Activity](https://img.shields.io/github/commit-activity/m/ROCKNIX/distribution?color=5998FF&style=flat-square)](https://github.com/ROCKNIX/distribution/commits) [![Pull Requests](https://img.shields.io/github/issues-pr-closed/ROCKNIX/distribution?color=5998FF&style=flat-square)](https://github.com/ROCKNIX/distribution/pulls) [![Discord Server](https://img.shields.io/discord/948029830325235753?color=5998FF&label=chat&style=flat-square)](https://discord.gg/seTxckZjJy)
#
ROCKNIX is a community developed Linux distribution for handheld gaming devices.  Our goal is to produce an operating system that has the features and capabilities that we need, and to have fun as we develop it.

## Licenses
ROCKNIX is a Linux distribution that is made up of many open-source components.  Components are provided under their respective licenses.  This distribution includes components licensed for non-commercial use only.

### ROCKNIX Branding
ROCKNIX branding and images are licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

#### You are free to
* Share — copy and redistribute the material in any medium or format
* Adapt — remix, transform, and build upon the material

#### Under the following terms
* Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
* NonCommercial — You may not use the material for commercial purposes.
* ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.

### ROCKNIX Software
Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Installation
* Download the latest version of ROCKNIX.
* Decompress the image.
* Write the image to an SDCARD using an imaging tool.  Common imaging tools include [Balena Etcher](https://www.balena.io/etcher/), [Raspberry Pi Imager](https://www.raspberrypi.com/software/), and [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/).  If you're skilled with the command line, dd works fine too.

### Installation Package Downloads
| **Device/Platform**                                                                                                                                              | **Download Package**                                                                                                                                                 | **Documentation**                                                    |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------|
| **Anbernic RG351P/M/V, Game Console R33S/R35S/R36S, ODROID Go Advance, ODROID Go Super, Magicx XU10, Powkiddy V10/RGB10**                                        | [ROCKNIX-RK3326.aarch64-$DATE-a.img.gz](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-RK3326.aarch64-$DATE-a.img.gz)                       | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK3326/)     |
| **Magicx XU Mini M, Powkiddy RGB10X**                                                                                                                            | [ROCKNIX-RK3326.aarch64-$DATE-b.img.gz](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-RK3326.aarch64-$DATE-b.img.gz)                       | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK3326/)     |
| **Anbernic RG353P/M/V/VS/PS, RG503, RGARC-D/S, Powkiddy RK2023, RGB10 Max 3, RGB30, RGB20SX, RGB20 Pro**                                                         | [ROCKNIX-RK3566.aarch64-$DATE-Generic.img.gz](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-RK3566.aarch64-$DATE-Generic.img.gz)           | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK3566/)     |
| **Anbernic RG552**                                                                                                                                               | [ROCKNIX-RK3399.aarch64-$DATE.img.gz](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-RK3399.aarch64-$DATE.img.gz)                           | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK3399/)     |
| **Anbernic RG35XX PLUS/H/SP/2024, RG40XX V/H, RGCUBEXX, RG34XX SP, RG28XX [Must Follow Install Instructions](https://rocknix.org/configure/h700-installation/)** | [ROCKNIX-H700.aarch64-$DATE.img.gz](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-H700.aarch64-$DATE.img.gz)                               | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/H700/)       |
| **Hardkernel ODROID Go Ultra, Powkiddy RGB10 Max 3 Pro**                                                                                                         | [ROCKNIX-S922X.aarch64-$DATE.img.gz](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-S922X.aarch64-$DATE.img.gz)                             | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/S922X/)      |
| **Gameforce Ace (default). Orange Pi 5 / 5 Plus, Radxa Rock 5a / 5b / 5b+ / CM5, and Indiedroid Nova**                                                           | [ROCKNIX-RK3588.aarch64-$DATE.img.gz](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-RK3588.aarch64-$DATE.img.gz)                           | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK3588/)     |
| **Powkiddy x55**                                                                                                                                                 | [ROCKNIX-RK3566.aarch64-$DATE-Powkiddy_x55.img.gz](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-RK3566.aarch64-$DATE-Powkiddy_x55.img.gz) | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK3566-X55/) |
| **Retroid Pocket 5, Pocket Mini, Pocket Mini V2, Pocket Flip2**                                                                                                  | [ROCKNIX-SM8250.aarch64-$DATE.img.gz](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-SM8250.aarch64-$DATE.img.gz)                           | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/SM8250/)     |
| **Ayn Odin 2, Odin 2 Mini, Odin 2 Portal, Thor, Ayaneo Pocket ACE/EVO/DMG/DS**                                                                                   | [ROCKNIX-SM8550.aarch64-$DATE.img.gz](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-SM8550.aarch64-$DATE.img.gz)                           | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/SM8550/)     |
| **Ayaneo Pocket S2**                                                                                                                                             | [ROCKNIX-SM8650.aarch64-$DATE.img.gz](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-SM8650.aarch64-$DATE.img.gz)                           | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/SM8650/)     |

## Upgrading
* Download and install the update online via the System Settings menu.
* If you are unable to update online
* Download the latest version of ROCKNIX from Github
* Copy the update to your device over the network to your device's update share.
* Reboot the device, and the update will begin automatically.

### Update Package Downloads
| **Device/Platform**                                                                                                                         | **Download Package**                                                                                                                 |
|---------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| **Anbernic RG351P/M/V, Game Console R33S/R35S/R36S, ODROID Go Advance, ODROID Go Super, Magicx XU10, XU Mini M, Powkiddy V10/RGB10/RGB10X** | [ROCKNIX-RK3326.aarch64-$DATE.tar](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-RK3326.aarch64-$DATE.tar) |
| **Anbernic RG353P/M/V/VS/PS, RG503, RGARC-D/S, Powkiddy RK2023, RGB10 Max 3, RGB30, RGB20SX, RGB20 Pro, X55**                               | [ROCKNIX-RK3566.aarch64-$DATE.tar](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-RK3566.aarch64-$DATE.tar) |
| **Anbernic RG552**                                                                                                                          | [ROCKNIX-RK3399.aarch64-$DATE.tar](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-RK3399.aarch64-$DATE.tar) |
| **Anbernic RG35XX PLUS/H/SP/2024, RG40XX V/H, RGCUBEXX, RG34XX SP, RG28XX**                                                                 | [ROCKNIX-H700.aarch64-$DATE.tar](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-H700.aarch64-$DATE.tar)     |
| **Hardkernel ODROID Go Ultra, Powkiddy RGB10 Max 3 Pro**                                                                                    | [ROCKNIX-S922X.aarch64-$DATE.tar](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-S922X.aarch64-$DATE.tar)   |
| **Gameforce Ace, Orange Pi 5 / 5 Plus, Radxa Rock 5a / 5b / 5b+ / CM5 and Indiedroid Nova**                                                 | [ROCKNIX-RK3588.aarch64-$DATE.tar](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-RK3588.aarch64-$DATE.tar) |
| **Retroid Pocket 5, Pocket Mini, Pocket Mini V2, Pocket Flip2**                                                                             | [ROCKNIX-SM8250.aarch64-$DATE.tar](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-SM8250.aarch64-$DATE.tar) |
| **Ayn Odin 2, Odin 2 Mini, Odin 2 Portal, Thor, Ayaneo Pocket ACE/EVO/DMG/DS**                                                              | [ROCKNIX-SM8550.aarch64-$DATE.tar](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-SM8550.aarch64-$DATE.tar) |
| **Ayaneo Pocket S2**                                                                                                                        | [ROCKNIX-SM8650.aarch64-$DATE.tar](https://github.com/ROCKNIX/distribution/releases/download/$DATE/ROCKNIX-SM8650.aarch64-$DATE.tar) |

## Documentation

### Contribute

* [Building ROCKNIX](https://rocknix.org/contribute/build/)
* [Code of Conduct](https://rocknix.org/contribute/code-of-conduct/)
* [Contributing to ROCKNIX](https://rocknix.org/contribute/)
* [Modifying ROCKNIX](https://rocknix.org/contribute/modify/)
* [Adding Hardware Quirks](https://rocknix.org/contribute/quirks/)
* [Creating Packages](https://rocknix.org/contribute/packages/)
* [Pull Request Template](/PULL_REQUEST_TEMPLATE.md)

### Play

* [Installing ROCKNIX](https://rocknix.org/play/install/)
* [Updating ROCKNIX](https://rocknix.org/play/update/)
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
* [Donating to ROCKNIX](https://rocknix.org/donations/)

## Change Log

### New Features
* Added...?

### Updates
* Updated...?

### Bug Fixes
* Fixed...?

**Full Changelog**: https://github.com/ROCKNIX/distribution/compare/$LAST_TAG...$DATE
