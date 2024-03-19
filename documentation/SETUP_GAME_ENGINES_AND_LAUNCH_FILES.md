&nbsp;&nbsp;<img src="https://raw.githubusercontent.com/JustEnoughLinuxOS/distribution/dev/distributions/JELOS/logos/rocknix-logo.png" width=192>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[![Latest Version](https://img.shields.io/github/release/JustEnoughLinuxOS/distribution.svg?color=5998FF&label=latest%20version&style=flat-square)](https://github.com/JustEnoughLinuxOS/distribution/releases/latest) [![Activity](https://img.shields.io/github/commit-activity/m/JustEnoughLinuxOS/distribution?color=5998FF&style=flat-square)](https://github.com/JustEnoughLinuxOS/distribution/commits) [![Pull Requests](https://img.shields.io/github/issues-pr-closed/JustEnoughLinuxOS/distribution?color=5998FF&style=flat-square)](https://github.com/JustEnoughLinuxOS/distribution/pulls) [![Discord Server](https://img.shields.io/discord/948029830325235753?color=5998FF&label=chat&style=flat-square)](https://discord.gg/seTxckZjJy)
#

# Game Engine Launch Files
Game engines such as Build Engine, GZDoom, LZDoom, ScummVM and ECWolf use launch files for launching the game with the specified files and mods. Most are configurable to enable different configurations of game files and mods per game.
> Note: the extensions for game engine launch files are case-sensitive, so make sure the launch extensions `.build`, `.doom`, `.scummvm` and `.ecwolf` are lower case, and make sure any references to game files match the case of the game files exactly (e.g. if the game file is `DOOM.WAD` then trying to launch it as `doom.wad` won't work).

## .build files
These files must be created for each build engine game that will be launched with raze. The file contains a `PATH` variable and an optional `GRP` variable. The `PATH` variable points to the subfolder containing the game's **GRP** file. The optional `GRP` variable is used to identify the specific **GRP** file to load for games with multiple **GRP** files.

Example: `/storage/roms/build/shadow warrior.build` contains
```
PATH=sw
GRP=SW.GRP
-- end --
```
where the Shadow Warrior games files are stored in subfolder `sw`, i.e. `/storage/roms/build/sw/`
> Note: don't leave any space between `GRP` or `PATH` and `=` and enclose filenames containing spaces with "quotes"

> Note: add `-- end --` to the end of the file if it contains multiple lines
 
## .doom files
These files must be created for each **WAD** that you want to load with gzdoom or lzdoom. The file contains `IWAD` variables and optional `MOD` variables. Multiple `IWAD` and `MOD` variables can be used in the same file to load multiple wads, mods and packages. Therefore, multiple **.doom** files can be created for the same **WAD** for each configuration of the game. It is recommended to store **WAD** files in a **iwads** subfolder and `MODs` in a **mods** subfolder and include the full path to each file in the **.doom** file.

Example: `/storage/roms/doom/doom.doom` contains
```
IWAD=/storage/roms/doom/iwads/doom.wad
```
to load vanilla doom
> Note: don't leave any space between `GRP` or `PATH` and `=` and enclose filenames containing spaces with "quotes"

Example: `/storage/roms/doom/heretic-mod.doom` contains
```
IWAD=/storage/roms/doom/iwads/heretic.wad
IWAD=/storage/roms/doom/iwads/IWMPP_Heretic.wad
MOD=/storage/roms/doom/mods/precise-crosshair-v1.4.1.pk3
MOD=/storage/roms/doom/mods/target-spy-v2.0.1.pk3
-- end --
```
to load Heretic with additional patches and mods.
> Note: add `-- end --` to the end of the file when it contains multiple lines

## .scummvm or .svm files
These files are created by `_Scan ScummVM Games.sh` script in `/storage/.config/scummvm` folder (which is also displayed in EmuStation). The script scans for game folders and generates the relevant `.scummvm` files to launch those games. The files are stored in `/storage/.config/scummvm/games`.  

`.scummvm` files are named using the common name of the game and the <a href="https://www.scummvm.org/compatibility/"> <strong>Game Short Name</strong></a> in brackets (e.g. `Beneath a Steel Sky (sky).scummvm`). 

`.scummvm` files contain a single line in the form:
* `--path=` variable and the path to the folder containing the game, *followed by*
* <a href="https://www.scummvm.org/compatibility/"> <strong>Game Short Name</strong></a>

Example: `/storage/.config/scummvm/games/Beneath a Steel Sky (sky).scummvm` contains
```
--path="/storage/roms/scummvm/Beneath a Steel Sky (CD VGA)" sky
```
> Note: enclose filenames containing spaces with "quotes"

> Note: `.scummvm` and `.svm` files are identical and interchangeable

> Note: the `.scummvm` files are **NOT** stored in `/storage/roms/scummvm` and any `.scummvm` files stored there will not be displayed by EmuStation. EmuStation only displays `.scummvm` files that are in `/storage/.config/scummvm/games`.

> Note: to display metadata and media within EmuStation, put `gamelist.xml` in `/storage/.config/scummvm/games` and media into relevant subfolders (e.g. `/storage/.config/scummvm/games/media` folder with `boxart`, `images` and `videos` subfolders)

## .ecwolf files
These files must be created for each Wolfenstein 3D compatible game. The file contains `PATH` variable that points to the subfolder containing the game's game files, `DATA` variable with the extension of the game files and `PK3` variables for each separate package file to load. `PK3` variables must be sequentially numbered with **_1**, **_2** etc.

Example: `/storage/roms/ecwolf/wolfenstein3d.ecwolf` contains
```
PATH=Wolfenstein 3D
DATA=WL6
PK3_1=/storage/roms/ecwolf/ecwolf.pk3
-- end --
```
where the Wolfenstein 3D game files have extension **.WL6**
> Note: the data value must match the file extension of the game exactly and is case sensitive so `WL6` is not the same as `wl6`

> Note: don't leave any space between `GRP` or `PATH` and `=` and enclose filenames containing spaces with "quotes"

> Note: add `-- end --` to the end of the file

Example: `/storage/roms/ecwolf/spear of destiny.ecwolf` contains
```
PATH=SOD
DATA=SOD
PK3_1=/storage/roms/ecwolf/SOD/ecwolf.pk3
-- end --
```
where the Spear of Destiny game files have extension **.SOD**
> Note: add `-- end --` to the end of the file


