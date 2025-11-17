Here your device tree overlays live.
Currently only mipi-panel.dtbo is expected which is intended for display driver stuff.

For R36s, rg351*-v2 and maybe other devices you may need to put a proper mipi-panel.dtbo
to make display work.
See https://rocknix.org/devices/unbranded/game-console-r35s-r36s/#new-displays-r36s-of-year-2024

Despite the name, mipi-panel.dtbo is also abused for quite a complex tuning
of EE clones of year 2025, but in this case the overlay is usually generated automatically.
In some cases (something is misdetected) you may want to replace mipi-panel.dtbo
with whatever you need.
See https://rocknix.org/devices/unbranded/EE-clones/#in-case-of-issues-with-displaysoundetc
