# ROCK 4D 6.1 vendor origin (2026-04-26)

Source: `arc@192.168.2.223:/home/arc/rock4dsdk/bsp/.src/linux`
kernel 6.1.84, board `rk3576-rock-4d`.

Newest DTS is `rk3576-rock-4d.dts` + `rk3576-rock-4d-panel.dtsi`
(panel dtsi dated 2026-04-26, one day newer than the base dts).
`rk3576-rock-4d-spi.dts` only adds SPI flash, unrelated to display.

Panel (1080x2160 MIPI, "6FHD"):
- `simple-panel-dsi`, 4 lanes, RGB888, 157 MHz
- backlight `sgmicro,sgm37604a` on i2c0@0x36, enable gpio3 PA0
- touch `sec,sec_ts` on i2c0@0x48, irq gpio2 PD5
- lcd power `vcc3v3_lcd0_n` gpio2 PB1, reset gpio0 PD1
- DSI routed from VP1

Migrated to mainline 7.0 as
`linux/dts/rockchip/rk3576-rock-4d-mipi-6fhd.dts`,
which is upstream `rk3576-rock-4d.dts` plus the panel fragment
below (UFS, wifi, leds, gmac, pcie, usb kept from upstream).
Panel/backlight/touch translated to `rocknix,generic-dsi` +
ported sgm37604a/sec_ts drivers.
