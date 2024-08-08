# Adding Hotkey Overrides
Quick Note: What are those weird boxes that represent the icons?

These are font-awesome glyphs! You can grab them by going to https://fontawesome.com/search?o=r&m=free, clicking the icon you want and then clicking on the smaller version of the icon *right* next to the download button in the upper righthand corner of the window. The tooltip will say "copy glyph". You can then paste these into your hotkey files as needed. **Please make sure to use free variants of icons.** Some color schemes in the same icons are *not* free and will ask for a license key if used.

## Per Game
1. Copy one of the existing hotkey files and rename it with the exact same name as the running executable.
    *. e.g. /usr/bin/mednafen = hotkeys/mednafen
2. Edit KEY_GUIDE_NONE to have the information you want displayed when *no hotkeys* are pressed.
    * This can be a nice message if nothing comes to mind.
    * One use case can be bindings for unique systems, like nintendo 64 or colecovision.
    * Another use case can be for direct hotkeys like PPSSPP's menu being bound to L3.
3. Edit KEY_GUIDE_1 to have the hotkeys you want displayed when SELECT (or FN1/Function 1) is held down.
    * More often than not these are the defaults, such as R1 to save state, etc.
    * You may or may not want to include globals as well, depending on how many keys you feel a user immediately needs (see default-hotkeys KEY_GUIDE_1 for a good maximum length)
4. Edit KEY_GUIDE_2 to have the hotkeys you want displayed when START (or FN2/Function 2) is held down.
    * Most of the time, these don't exist and you'll just have the "Disable Wifi" global. There are exceptions like Mednafen and Dolphin, etc.
5. Edit KEY_GUIDE_3 to have the information you want displayed when both SELECT/FN1/Function 1 *AND* SELECT/FN2/Function 2 are held down at the same time.
    * The vast majority of the time, some variant of this is the EXIT hotkey. So you want this to be information regarding additional conditions to exit (press start again, continue holding, hold down L and pres start again) or informing the user that it is now exiting if there are none.

## Per Device (WIP)
Note quite sure how to do this yet. I'm thinking maybe an device quirk tmp state that, if exists, will alter (sed) the entire current-hotkeys in runemu.sh. e.g. swap Y for X in the RG-ARC, SELECT for FN1 in the RGB10MAX3 and Gameforce ACE, etc. This will alter it just before application run, so the changes will not be permanent when the SD is swapped into another device.