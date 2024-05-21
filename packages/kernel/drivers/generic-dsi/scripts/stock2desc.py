#!/usr/bin/env python

# https://pypi.org/project/fdt/
# pip install fdt

import sys
import fdt

with open(sys.argv[1], "rb") as f:
    dtb_data = f.read()

dt = fdt.parse_dtb(dtb_data)
panel = dt.get_node("dsi@ff450000/panel@0")

w = panel.get_property("width-mm").value
h = panel.get_property("height-mm").value

delays = [
        panel.get_property("prepare-delay-ms").value,
        panel.get_property("reset-delay-ms").value,
        panel.get_property("init-delay-ms").value,
        panel.get_property("enable-delay-ms").value,
        20  # ready -- no such timeout in legacy dtbs
        ]
delays_str = ','.join(map(str, delays))

fmt = ['rgb888', 'rgb666', 'rgb666_packed', 'rgb565'] [panel.get_property("dsi,format").value]
lanes = panel.get_property("dsi,lanes").value
flags = panel.get_property("dsi,flags").value
flags |= 0x0400

# G size=52,70 delays=2,1,20,120,50,20 format=rgb888 lanes=4 flags=0xe03
print(f"G size={w},{h} delays={delays_str} format={fmt} lanes={lanes} flags=0x{flags:x}\n")


timings = panel.get_subnode("display-timings")
native = timings.get_property("native-mode").value
# M clock=27500 horizontal=640,50,2,90 vertical=480,18,2,8
for m in timings.nodes:
    clock = round(m.get_property("clock-frequency").value/1000)
    hor = [
            m.get_property("hactive").value,
            m.get_property("hfront-porch").value,
            m.get_property("hsync-len").value,
            m.get_property("hback-porch").value,
            ]
    hor_str = ','.join(map(str, hor))
    ver = [
            m.get_property("vactive").value,
            m.get_property("vfront-porch").value,
            m.get_property("vsync-len").value,
            m.get_property("vback-porch").value,
            ]
    ver_str = ','.join(map(str, ver))
    maybe_default = ""
    if (m.get_property("phandle").value == native):
        maybe_default = " default=1"

    print(f"M clock={clock} horizontal={hor_str} vertical={ver_str} {maybe_default}")

print()

iseq0 = panel.get_property("panel-init-sequence")
if (hasattr(iseq0, 'value')) and (isinstance(iseq0.value, (int))):
    iseq = b''.join(map(lambda w : w.to_bytes(4, "big"), list(iseq0)))
else:
    iseq = bytearray(iseq0)

while iseq:
    cmd = iseq[0]
    wait = iseq[1]
    datalen = iseq[2]
    iseq = iseq[3:]

    data = iseq[0:datalen]
    iseq = iseq[datalen:]

    maybe_wait = f" wait={wait}" if (wait) else ""
    print(f"I seq={data.hex()}{maybe_wait} # orig_cmd=0x{cmd:x}")
