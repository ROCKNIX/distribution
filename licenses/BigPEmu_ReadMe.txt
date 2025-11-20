Title: BigPEmu
Version: 1.19
Author: Rich Whitehouse
Website: https://www.richwhitehouse.com/jaguar/
Description: An Atari Jaguar emulator, featuring compatibility with every title in the Jaguar's retail library. See below for copyright and licensing information.


Patreon: /richwhitehouse
https://patreon.com/richwhitehouse

Bluesky: @richwhitehouse.bsky.social
https://bsky.app/profile/richwhitehouse.bsky.social

Twitter: @DickWhitehouse
https://twitter.com/DickWhitehouse

Please consider showing your support!


Release Notes
-------------
Version 1.19
 - Added some more unaligned read/write edge case handling. This addresses a problem in Theme Park, possibly among other things.
 - Changed some undocumented RISC instruction behavior to match some of my local hardware tests. One of these changes is known to correct an issue with object directions in Defender 2000.
 - Added more Jaguar GD functionality. Filesystem functions are stubbed out, but I wasn't sure if anyone really needs/wants this fully implemented, so let me know if it's important to you.
 - Fixed a few "undefined" Blitter cases. (not known to affect any existing titles)
 - Linux ARM64 builds are now part of the automated build set. Special thanks to cubanismo for guiding me through the minefield of cross-compiling for ancient Linux targets.
 - Significant improvements to the network rollback functionality, propagated back from BigInstinct.
 - All kinds of new platform/framework functionality, also propagated back from BigInstinct. I didn't feel like going through hundreds of changes to make a coherent summary, but one of the more notable additions is a byuu-style run-ahead option.
 - Exposed a bunch of sound spatialization functionality to the scripting API.
 - Exposed MOD and MP3 playback to the scripting API.
 - Added a timing fix for Val d'Isere Skiing and Snowboarding.
 - Various developer build changes to more accurately reflect hardware and/or detect errors which would break on non-developer builds. (this includes enabling M68K address exceptions)
 - Lots of "anti-emulator" code will be failing in developer builds at this point, and some related functionality may be propagating to non-developer builds soon; relying on inaccuracies to prevent your software from running in BigPEmu is unwise. If you really want to prevent your software from running in BigPEmu, contact me about better/future-proof methods.

Version 1.18
 - New Steam integration! This includes support for game servers, friends/invites, rich presence, and more. At the time of this writing, Valve is still holding the actual Steam release up over some petty nonsense. (like supported categories and Patreon references)
 - Added a script for Breakout 2000 touch control. The paddle is horizontally positioned to match the first active touch.
 - Added an audio interpolation setting, along with a higher-quality bandlimited audio interpolator.
 - Added an option to change the size of the state operation undo buffer.
 - Exposed a few more network settings.
 - Added options for PvP damage scaling and infinite shotgun ammo to the AvP MP script.
 - Added another terrible secret.
 - Fixed a bunch of problems in the socket implementation for non-Windows platforms. Special thanks to Luigi for spending the entire morning of December 4, 2024 helping me debug these problems and for offering some excellent tips on developing class consciousness. (he's a big fan of OOP)
 - Various changes/optimizations in the network protocol.
 - Fixed swipe velocity not being explicitly reset when entering the menu.
 - Fixed a GUID conflict bug in the SDL2 input plugin. Thanks to Tartifless for the bug report.
 - Fixed script input callbacks having the potential to break movie recording/playback.

Version 1.17
 - Added a script for Raiden touch control. Ship automatically travels to the touch point and auto-fires when held, with a 2-finger tap to trigger bombs.
 - Added a script for Vid Grid touch control. Drag and drop!
 - Added a script for Towers II touch control. (with an option to uncap the framerate) In-game menu cursor is touch-driven, 2-finger tap exits the menu.
 - Added a script for Myst touch control. Hold to drag the cursor, tap to activate.
 - Added some scripting functionality to allow setting custom read/write handlers for non-RAM/ROM memory regions.
 - The iOS port now prompts the user to determine their battery/heat versus performance preference on first run. (since we can't just be energy-efficient without the iOS scheduler punishing us, and I'm not having any luck getting anyone to read the FAQ/user manual)
 - The iOS port now has a separate "Connected Idle Time" setting, which defaults to 3.0 and is used instead of "Overlay Idle Time" when at least one external device is connected. (workaround for the same FAQ/user manual problem above)
 - Added lots of random new scripting functionality.
 - Fixed game thumbnails rendering at the incorrect scale in portrait mode.

Version 1.16
 - The iOS port is done, get it on the App Store here: https://apps.apple.com/us/app/bigpemu/id6737359949 Special thanks to neurocrash for putting so much time into testing the iOS build for me.
 - Lots of new interface functionality (including a touch-based interface option), courtesy of the mobile port work. All of this functionality can be accessed through the menu on non-mobile platforms.
 - Multi-touch device support has been added for the Windows (x64 and ARM64) platforms, in order to take advantage of the touch interface work done for the mobile ports.
 - Added a "Pad Wheel" feature, which can be activated through the input binding system.
 - Support for a new BigPImage disc format. BigPImage files can be created from existing images or physical discs through the developer menu. Before anyone asks, CHD support looked problematic for quite a few reasons (mostly pertaining to the likelihood of image-based performance problems and implementation bloat inherent to the format), making this new format a much more optimal choice for the particular needs of this emulator.
 - Added stereoscopic rendering support to the AvP script.
 - Added a new DOOM script with throttling and music options.
 - Added a new turbo/rapid fire script.
 - Added a "Factory Reset" option, as a convenient means of resetting the configuration across all categories.
 - Added an option to auto-assign new input devices. Devices will not be auto-assigned if they have any existing associations with any Jaguar inputs.
 - Fixed an incredible number of bugs, pertaining to both interface and emulation. Because so many fixes have been made to the emulator core in this release, I'm especially interested in finding regression bugs. Please let me know if you experience any issues which don't occur in 1.15.

Version 1.15
 - Added a pure software video plugin for Windows builds. This plugin is primarily intended for development and diagnostic purposes, and is only visible in developer mode.
 - New Noesis debugger scripting functionality for developer builds, this enables several new features. Make sure you're using the newest version of Noesis to take advantage of the functionality.
 - Added -uiscale, -menunodex, and -menunodey command line options.
 - Added a recalibration option under the Input menu.
 - Added several more native window management functions to the script API.
 - Added an optional flags parameter to the "opdump" debugger command, check the "help" output for details.
 - Added the most terrible secret of all.
 - Fixed a problem with directory checks on UNC paths under Windows, thanks to King Puff for the bug report.
 - Lots of smaller fixes/changes in preparation for more port/interface functionality.

Version 1.14
 - Added bigpemu_register_event_audio_frame, scripts are now able to read/modify audio frames.
 - Added various audio/sampling utility functions to the scripting system. (see the spectrum analyzer sample usage in hello_pussycat and the full list of functions in bigpcrt.h)
 - Added bigpemu_set_named_var_data and bigpemu_get_named_var_data, along with a "ScriptOption" Screen Effect data provider type. This allows script code to drive Screen Effect data, see hello_pussycat and liz for example usage.
 - Added bigpemu_native_window_handle, as a convenience for scripts which may want to pass the window handle to a native DLL.
 - Added support for the "physical disc" path under Linux. This will only function correctly with drives (virtual or otherwise) which support raw subchannel reads.
 - Fixed a potential developer build crash from forcing script reloads while employing conditional breakpoints.
 - Fixed an issue which could result in the application window being positioned incorrectly after switching to fullscreen.
 - Fixed some SDL2-specific fullscreen/multi-monitor issues. Thanks to cubanismo for nudging me into investigating this.

Version 1.13
 - Fixed a problem which resulted in some of the built-in D3D12 shaders requiring Shader Model 6.0.
 - Added more logging for various D3D12 initialization failure cases.

Version 1.12
 - New D3D12 video plugin. The shader tool has also been updated and supports generating DXIL.
 - New Windows ARM64 builds. Less frequently used platform-dependent functionality may remain unimplemented on this platform.
 - Added a Blitter capture feature for developer builds. See the "blitcap" debugger command.
 - Various minor cross-platform fixes which came along with the new port/backend work.

Version 1.11
 - Unmapped input labels now display an angle suffix for hat switches.
 - Unmapped input labels now display a +/- prefix for analog bindings, when applicable.
 - Added a -forcegpusync command line option.

Version 1.1
 - Added a native Linux (x64) port. Generally not well tested, but seems to be working well enough in local testing under a couple of different distributions. Less frequently used platform-dependent functionality may remain unimplemented on this platform.
 - Added a new SDL2 plugin for audio, video, and input. Not particularly recommended under Windows, but a Windows build is provided nonetheless.
 - Added custom sky/background functionality to the Checkered Flag script.
 - Added an "Alternate Scheduling" option.
 - Added a "Rewind Skip" option.
 - Added a "Frame Time Display" developer option.
 - Fixed a minor interrupt timing issue.
 - Fixed a bug in the object browser which could, rarely, result in a memory leak.
 - Fixed a bug preventing BIGPEMU_TEXFLAG_REPEAT from affecting texture wrap mode in the OpenGL video plugin.
 - Fixed another timing issue, which was manifesting as a rare crash in Cybermorph. Thanks to Will for managing to capture a saved state illustrating this problem.
 - Developer builds will avoid crashing and warn the developer (via connected debugger) when a read/write straddles the end of ROM. Normal builds will still crash, in order to avoid overhead. Thanks to DrTypo for the bug report.

Version 1.094
 - The Checkered Flag "Uncap Framerate" option can now be switched between 30Hz and 60Hz.
 - Added some sync code to the Checkered Flag script to fix possible flickering issues. (only became noticeable at 60Hz)
 - Checkered Flag is generally playable at 60Hz, but you're likely to encounter more timing bugs. Native system requirements are also significantly higher, as the Jaguar is automatically overclocked in this mode.

Version 1.093
 - Added a Checkered Flag script, which features native resolution rendering, analog controller support, framerate unlocking, and lots of tweaks/options.
 - Added a new Tempest 2000 script to patch some of the rotary controller bugs that existed on hardware.
 - Added support for "AUDIOWITHSUB" track types in the CUE loader.
 - Added an "optree" debug command. (only relevant for developer builds)
 - Added a "gfxflags" debug command. (only relevant for developer builds)
 - Added bigpemu_jag_op_render_bitmap_object_to_buffer to the scripting API.
 - Native CRY rendering and ADDDSEL blending is now supported through the native polygon script interface.
 - New scripting functionality to hook into save/load state events, allowing scripts to pack custom data into saved states.
 - Fixed a potential resource leak when associating textured native polygons with a buffer.
 - Fixed changes to the MSAA setting sometimes not being reflected until restarting the application.
 - Fixed potential flickering and other visual problems after re-allocating native polygon hardware buffers.
 - Fixed the script function bigpemu_drawui_get_virtual_to_native_scales returning incorrect values.
 - Fixed an issue with one of the terrible secrets which was making the secret slightly less terrible than designed.

Version 1.092
 - Added an optional rewind feature, see the new "Rewind Count" setting as well as the new "Rewind" key bind.
 - Added an optional network rewind feature, see the "Network Rewind" setting under the Network menu. Rewinds the state and immediately runs the emulator back to the current frame when an input discrepancy occurs. Requires a powerful machine to avoid hitches. (emulating Jaguar frames isn't cheap)
 - Added analog/mouselook support to the AvP script.
 - Added a new Wolfenstein 3D script with analog/mouselook support. (includes always-strafe and always-run options)
 - Added a new Iron Soldier script with analog/mouselook support.
 - Minor performance improvements.

Version 1.091
 - AvP multiplayer fixes.
   - Fixed some player projectile weapons not colliding with other players.
   - Fixed a bunch of AI projectiles not being correctly synchronized.
   - Fixed an issue which would sometimes cause AI to stop attacking.
   - If a human player teleports into a new level without a weapon, the shotgun is now automatically granted.
   - Fixed a bug which could sometimes cause bigpemu_net_behind to misreport.
   - New script functions: bigpemu_net_hostmsg, bigpemu_net_disconnect, and bigpemu_net_lastclient.

Version 1.09
 - New "State Sync" network device type, synchronizes system state across the network. This allows local 2-player games to be played over Internet/LAN connections.
   - Very simple implementation that just stalls out if input doesn't arrive in time. State Sync Delay option adjusts the anticipated latency window. If you run into timing issues, the host can manually kick everyone back together by loading a state.
   - State Sync Remap can be used to remap the first local input device to any other input device. Also allows overlapping controls. (e.g. two peers both affecting the first input device)
   - Works with any number of clients, with clients above the supported input device count being treated as spectators.
 - New "Script" network device type, allows scripts to implement custom network/socket handlers. Includes automatic delta compression and some other niceties.
 - A new script adds multiplayer to AvP!
   - Implements networking from scratch using the aforementioned socket interface, and works with the unmodified retail ROM image.
   - Proper client-server architecture, up to 32 players can drop in at any time during gameplay. (in theory)
   - Generally handles the fundamentals, but expect plenty of limitations, bugs, and odd behavior. This game wasn't designed to support multiplayer, and I've left a few threads hanging under the guise of "shippable."
   - Enemies can correctly change off between player targets.
   - I hope this serves as another demonstration of the sort of madness which can be accomplished with the scripting system, and I'd love to see others give this sort of treatment to more titles.
 - Lots of new scripting/VM functionality.
   - UI event callbacks for custom rendering over/under the rest of the UI.
   - New UI rendering functions for various primitives and text.
   - Input functions to allow querying input states across all native devices.
   - Scripts can now load and render/play texture and sound resources.
   - New native-backed 4x4 matrix/transform operations.
   - Script can now get a list of ROM from from the current ROM directory, and load images in that directory.
   - Scripted polygon texture references now have the option of pointing to native texture resources. Could be useful for something like a high-res texture replacement script.
 - Fixed a floating point comparison bug in the VM interpreter.
 - VM modules are now loaded automatically if a .bigpcvm file is present with the same name as the ROM image being loaded, similar to other image-specific resources. This allows Jaguar software to be distributed alongside emulator-specific script enhancements.

Version 1.08
 - JagLink support is here!
   - Max player count is supported in AirCars and BattleSphere, with the potential for any number of emulated Jaguars to be networked together.
   - Special splitscreen functionality has been added.
   - Works over Internet/LAN or locally via loopback.
     - Don't expect anything to be playable or stable over the Internet unless you've got LAN-like latency and no packet loss.
   - When the central host loads a saved state, it's automatically propagated to all clients.
   - Here's a video which goes over all of the network features and demonstrates a splitscreen setup: https://youtu.be/b2e7Vl4aLps
 - Added -cfgpath and -cfgpathabs command line options. This overrides the default config path, useful for splitscreen instances.
 - Added -windowx and -windowy command line options. Useful for tiling out instances for splitscreen play.
 - Added a -noborder command line option. Removes the border from the window in windowed mode, best used with -windowx, -windowy, -forcewidth, and -forceheight.
 - Added an -alwaystop command line option. Keeps the window always-on-top, also useful for splitscreen mode.
 - Added -netlisten, -netconnect, -netport, -netmax, -netloaddelay, -netpcldelay, and -nettcp command line options.
 - Bumped the debugger protocol version, make sure you update to the latest Noesis if you're using the developer build.

Version 1.071
 - Fixed a bug which was causing the VR Swap Eyes setting to be incorrectly tied to other settings. This probably explains reports from some users of being "cross-eyed" by default.
 - Added stereoscopic rendering support for the GPU list variant used by the MC3D stage 1-3 boss.

Version 1.07
 - Jaguar VR support is here, with head tracking and stereoscopic rendering.
   - A new Head Tracker input device type has been added, along with some options for converting analog inputs to tracker angles.
   - Stereoscopic rendering is fully implemented, and integrated into the scripting system.
   - Check out all the new settings in the Video/VR menu.
   - The scripting system has the potential to add Head Tracker support and stereoscopic rendering to any Jaguar title, so more Jaguar VR games may be coming!
   - This video demonstrates and explains some of the new VR functionality: https://youtu.be/BAJjzlrsbis
 - Added an OpenVR plugin to support the new Jaguar VR implementation.
 - A new script is included to implement stereoscopic rendering and enable Head Tracker support in the final/retail version of Missile Command 3D.
   - To map the head tracking through any analog input with the script enabled: set the second input device type to "Head Tracker", and bind the second device's analog inputs to whatever pleases you.
   - To enable stereoscopic rendering with the script enabled: go to Script Settings in the menu and enable the stereoscopic rendering option. Stereo-capable scenes will be rendered using the emulator's selected VR/anaglyph 3D settings.
   - When VR is enabled (via the Video/VR settings) and successfully initialized, if a compatible headset is present, its orientation will automatically feed the Head Tracker input.
   - Stereoscopic rendering was never actually implemented in MC3D, this is a brand new software feature designed to fully realize the potential of Jaguar VR.
 - Fixed a Blitter issue with DCOMPEN in phrase mode. (introduced in the Patreon-exclusive 1.061 build)
 - Lots of changes/additions for developer mode, and separate debugger-enabled builds are now available from the official web site. Check the ReadMeDev.txt file in the debugger-enabled build distribution for more information. (introduced in the Patreon-exclusive 1.061 build)

Version 1.06
 - New scripting system. In developer mode, scripts are auto-recompiled on startup. Developer options are also available to automatically detect script changes while the application is running. Compiled scripts must be enabled through a new Script Modules feature.
 - A new script is included which allows Cybermorph to render polygons/textures at the native resolution.
 - An option for adjusting MSAA has been added to the video settings. This is only relevant to things which use the native depth buffer, like the new Cybermorph script.
 - A new script is included which allows uncapping the framerate in Alien vs. Predator.
 - A new script is included which fixes flickering in the Brett Hull Hockey prototype.
 - A simplified CRT library along with a whole bunch of BigPEmu-specific API functionality is included in the scripting system via the Scripts/bigpcrt library.
 - Basic native DLL (CDECL) call functionality has been implemented in the scripting API, so that others can take the initiative to start implementing things like RetroAchievements as desired.
 - Added native mouse input support. (must be enabled in the input settings) Mouse movement and buttons can be bound to analog, rotary, and digital inputs interchangeably.
 - Some more work on debugger-enabled builds has been done behind the scenes, but this shouldn't affect anything user-facing just yet.
 - Even more terrible secrets have been added.
 - Made sure native rendering works even with a Screen Effect active. However, this isn't generally a recommended combination, as the effect will be sourcing from a native-resolution buffer instead of a Jaguar-resolution buffer. (post-Patreon build addition)
 - Added a -conout command line option. Under Windows, this spawns a console and directs log output here instead of to a file. (post-Patreon build addition)
 - The breadth of functionality encompassed by the scripting system is too vast to cover here, so I've made a video to highlight some of the features and explain how the existing scripts work: https://youtu.be/y4gXxSmLOg4
 - Please help me out with support on social media and Patreon! Things have continued to be rough on the health front lately, and I've found it's getting harder to use Twitter to reach my actual target audience, so I'm depending more on organic word of mouth to spread project news and hopefully bring in support.

Version 1.054
 - Made some adjustments to the refresh rate warning logic introduced in the last version. The warning is inhibited when VSync is disabled (no, don't do it!), and an option to disable the warning has been added.

Version 1.053
 - VLM's CD+G support is now working.
 - Refresh frequency can now be specified when selecting a display mode. (previously, the highest available was auto-selected)
 - The program will now warn you if you're using a native display refresh rate which is lower than the Jaguar's current display frequency. (50Hz for PAL, 60Hz for NTSC)
 - There's now a warning under the Mount Images menu telling users to avoid setting a cartridge image with a disc image if the two were not designed to run together. Depending on the CD BIOS (and if one is set at all), this can cause a wide variety of problems, so don't do it.
 - Fixed a Blitter issue which was introduced several versions ago. The issue could result in crashes, especially when running Fight for Life.
 - Fixed a problem with SUBQMOD, although there are no known instances where this fix changes any behavior in the retail library.
 - Fixed more unmapped read behavior which was preventing some homebrew from running correctly.
 - Fixed a Blitter negative base address issue.
 - Various other minor bug fixes. Thanks to all of the people who submitted bug reports through the web site!

Version 1.052
 - Added a "Sample Scale" option for the System Audio Disc.
 - I heard you like minor timing fixes, so I made some minor timing fixes to the minor timing fixes.

Version 1.051
 - Minor timing fixes.

Version 1.05
 - Jaguar CD support! This encompasses a whole bunch of new functionality. Thank you to Mycah Mattox for donating the Jaguar CD hardware, this hardware was essential for my research.
 - Added -nodevicechange and -fulldevrefresh as command line options.
 - Added -forceloadaddr and -forcerunaddr as command line options.
 - Added -setcfgprop and -setcfgpropcat as command line options.
 - Added -audiocapindex as a command line option, can be used when launching *VirtualDisc_SystemAudio as the ROM image via command line.
 - Added -physdevindex as a command line option, can be used when launching *VirtualDisc_SystemPath as the ROM image via command line.
 - Added another DirectInput workaround which may help prevent stuck analog controls on some machines. Thanks to neurocrash for spending a lot of time running tests for me on a machine where this was an issue!
 - Fixed a problem with depth writes in 32-bit mode, thanks to 42Bastian for providing a test case.
 - Fixed an issue with word strobes not being correctly scheduled until a write to SMODE/SCLK. (only relevant when running with no boot ROM set)
 - Fixed a timing problem with EEPROM reads.
 - Fixed scaling on monitors with a non-standard DPI.
 - When adding a new individual input trigger in the binds menu, the prompt mode now defaults to "specify hold and button" instead of just "specify button". (in line with binding all inputs via "Set All")
 - Lots of additional core emulation fixes which came along with CD support.
 - Implemented some intentional redundancy in the OpenGL video plugin's state management, to guard against things like Discord's video capture poking around in the context without cleaning up after itself.
 - With CD support wrapped up, I'm taking a short hiatus! I need to recouperate, generate some income, and prepare for the next phase of my cancer treatment. Please don't inundate me with fix/feature requests via e-mail/Discord/etc. during this time. Instead, I ask that you use the less invasive Bug Report form on the web site. Thank you for your consideration!

Version 1.04
 - Added -devmode as a command line option. Don't get too excited, this isn't opening up full developer build functionality just yet. (and the option will be auto-enabled in proper developer builds) It does enable a developer menu, though, and some additional developer-oriented key binds.
 - Added a "Local EEPROM" option to the new developer menu at CJ Reboot's request.
 - Added a "Save Window Position" option to the new developer menu at CJ Reboot's request.
 - Added an "Always on Top" option to the new developer menu at CJ Reboot's request.
 - Added a new set of developer input binds, which are only accessible when using -devmode. Most of these new binds were added at 42Bastian's request.
 - Now picking through individual device/state changes instead of just refreshing all input devices when a DEVNODES_CHANGED-type message is received. Fixes input disruptions on machines where something is causing DEVNODES_CHANGED spam.
 - Fixed a problem when recording a movie with the "Increment on Save" setting enabled. Thanks to Doug Engel for finding this bug!
 - Fixed a crash when entering the Zero 5 sound options screen.
 - Every issue which was submitted through the Bug Report form on the website has now been resolved. Thanks to everyone who contributed! If you submitted something which still isn't resolved in this build, let me know.

Version 1.03
 - Fix for some emulator state overrides not sticking when launching software via command line.

Version 1.02
 - Added interlaced display support. This is definitely not working the way it works on hardware, but it addresses the test case that Doug Engel was kind enough to send over.
 - Added a "force horizontal overscan" option.
 - Added an option to force Jaguar GD emulation, which enables bank switching even in ROM images smaller than 6MB.
 - Added -localdata as a command line option.
 - Changed the first visible column default. (applies to both NTSC and PAL)
 - Fix for a 16-bit DAC write bug. (fixes one-sided audio in Super Burnout)
 - Fix for a problem on the Blitter's SRCSHADE data path. Thanks to Doug Engel for reporting the BattleSphere bug which led to this fix. 
 - Fix for OP sometimes running over HDE, thanks to CJ Reboot for reporting the associated bug.
 - Fix for input bindings sometimes not being picked up from per-game config files. This bug could also potentially cause game-specific bindings to "stick" and infect the global config bindings.

Version 1.01
 - Added variable-sized EEPROM support, thanks to CJ Reboot for providing some test cases. 512 byte and 2KB EEPROM settings are picked up from the MRQ file if it exists, otherwise any number of EEPROM address bits can be specified via the -eeprombits command line option.
 - Added Jaguar GD bank switching support.
 - Fix for exception-handled M68K reads in unmapped address space.
 - Fix for Blitter not correctly wrapping cyan/red on add when ADDDSEL is set, thanks to Doug Engel for reporting the BattleSphere bug which led to this fix.
 - Fix for Blitter not starting on the correct bit when block width is less than pixel size and phrase mode is not enabled, thanks to Doug Engel for reporting the BattleSphere bug which led to this fix.
 - Going in for a major surgery tomorrow (2022/12/06), so expect that I'll be mostly unavailable and that there won't be any emulator updates for at least a couple of weeks.

Version 1.00
 - First public release!


Troubleshooting
---------------
If you're encountering problems with BigPEmu after a successful first use, the first thing you should try is clearing out your configuration. You can do this by deleting the BigPEmuConfig.bigpcfg in your %APPDATA%\BigPEmu folder. (this is usually somewhere like C:\Users\YourUsername\AppData\Roaming\BigPEmu)

If you have a different problem or your problem persists after deleting your configuration file, check the website for additional help and information.


Copyright, Permissions, and Special Thanks
------------------------------------------
BigPEmu Copyright (C) 2022 Rich Whitehouse

Special thanks to everyone at Digital Eclipse, especially Mike Mika and Stephen Frost! These guys helped fund the development of this emulator, and helped make sure I'd be able to release it publicly. In the video game industry, that's a real gesture of love.

Extra special thanks to Mark Sowden (hogsy) for being a friend and long-time supporter of my work.

Even more special thanks to Mycah Mattox for donating a Jaguar CD unit!

Those Who Bare Fangs at God:
 - Mark Sowden (hogsy)
 - John Perez (neurocrash)
 - Benjamin Bettridge
 - Jan D. (thank you for going so far above and beyond)
 - ZoeB
 - Scott LeGrand
 - William Thorup
 - Dan McCombs
 - noigeaR
 - Luigi Mangione (thank you for your sacrifice)
 - B.J. West
 - Shannon Gates
 - Havard Vatne
 - Tony Walsh
 - guru emulation
May your oppressors suffer all the torments this world has to offer, my friends.

Thank you to my daughter, Alaura, for brightening my life from the moment of her birth.

Thank you to my wife and my good friends (Ruth, Joseph, Boris, Jake) for helping me through (the remains of) my life as I suffer with cancer.

As with all of the free software that I write, I accept no liability and offer no warranty. By using this software, you agree that you are solely responsible for any form of harm which may result from the use of this software.

I forbid the use of this software for any form of private financial gain. You may not distribute this software without the inclusion of this document in unmodified form, and you may not distribute modified versions of the main BigPEmu executable file. Any exemption from these terms requires my written permission.

For a list of third party software included in BigPEmu and the corresponding license/copyright information, please see the Data/ThirdParty/Licenses directory. (location may vary per platform/distribution, check the application documents folder on iOS/macOS) I've also auto-converted and included a few shaders written by Hyllian under the MIT license, see the relevant shader files in Data/ScreenEffects for the original license/copyright information.

BigPEmu: The World's Prefurred Large Pussycat Emulator

I'd say I'm going to hell, but I'm already there!
