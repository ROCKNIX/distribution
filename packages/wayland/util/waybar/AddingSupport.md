# Adding Waybar Support
Waybar requires the game to not request exclusive fullscreen, due to the fact that sway adheres strictly to wayland/wlroots standards.

This largely means one of three things:
1. The emulator or game will just run out of the box because it does not request it in the first place.
2. You need to disable fullscreen or set it to windowed mode by config or command line, with it ideally scaling and behaving ok once you do.
3. You need to use some sort of fancy workaround depending depending on if it supports a fullscreen binding.

You do not have to worry about resolutions, sway will maximize the window based on your framebuffer. Debugging for said workarounds in #3 is described in the next section.

## Debugging Steps for Workarounds.
1. Try to find a native fullscreen disable.
2. If the native fullscreen disable does not behave ok (it does not center or scale correctly), check to see if it has a fullscreen toggle binding, namely alt+enter or ctrl+f.
    - If so, copy the gptk (gptokeyb) setup form flycast or mednafen. This gives a binding of SELECT/FN1 + L1 to toggle fullscreen. It does not conflict with mednafen load state because you must hold it for two seconds. 
3. If *neither* a native disable nor a binding for toggling fullscreen exist, open up the game, ssh, and run "swaymsg fullscreen toggle".
4. If #3 works without issue, please also run "swaymsg -t get_tree | jq '.. | select(.focused?) | .app_id'", and create a line in sway/config/config.kiosk
5. If #3 works, *but misbehaves* similar to #2, copy the gptk setup from step 2, except set your bindings to "l1_hk: f" and "l1_hk: add_alt".
6. If nothing works you're out of luck, contact the portmaster maintainer or devleoper.