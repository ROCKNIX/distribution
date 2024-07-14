#!/usr/bin/env python

# https://pypi.org/project/fdt/
# pip install fdt

import sys, argparse
import fdt
import math

parser = argparse.ArgumentParser(description="Extract MIPI panel description from stock dtb to use with panel-mipi-generic driver")
parser.add_argument("-n", "--name", help="human readable panel name")
parser.add_argument("-O", "--dtbo", help="store result in ready to use .dtbo file")
parser.add_argument(metavar="/path/to/vendor.dtb", dest="source_dtb", help="dtb file from stock firmware")
args = parser.parse_args()

with open(args.source_dtb, "rb") as f:
    dtb_data = f.read()

acc = []

g_name = f"name='{args.name}' " if args.name else ""

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
acc += [f"G {g_name}size={w},{h} delays={delays_str} format={fmt} lanes={lanes} flags=0x{flags:x}", ""]


timings = panel.get_subnode("display-timings")
native = timings.get_property("native-mode").value

# Collect vendor modes
modes = {}
orig_def_fps = None
for m in timings.nodes:
    clock = round(m.get_property("clock-frequency").value/1000)
    hor = [
            m.get_property("hactive").value,
            m.get_property("hfront-porch").value,
            m.get_property("hsync-len").value,
            m.get_property("hback-porch").value,
            ]
    ver = [
            m.get_property("vactive").value,
            m.get_property("vfront-porch").value,
            m.get_property("vsync-len").value,
            m.get_property("vback-porch").value,
            ]

    mode = {'clock': clock, 'hor': hor, 'ver': ver}
    if (m.get_property("phandle").value == native):
        mode['default'] = True

    htotal = sum(hor)
    vtotal = sum(ver)
    fps = clock*1000/(htotal*vtotal)

    if fps not in modes:
        modes[fps] = mode
    if (m.get_property("phandle").value == native):
        modes[fps]['default'] = True
        orig_def_fps = fps


def absfrac(x):
    return abs(x - round(x))

# Based on vendor modes construct a better set of modes
# https://tasvideos.org/PlatformFramerates
# 50, 60        -- generic
# */1.001       -- NTSC hack with 1001 divisor
# 50.0070       -- PAL NES  https://www.nesdev.org/wiki/Cycle_reference_chart
# 60.0988       -- NTSC NES
# 54.8766       -- src/mame/toaplan/twincobr.cpp
# 57.5          -- src/mame/kaneko/snowbros.cpp
# 59.7275       -- https://en.wikipedia.org/wiki/Game_Boy
# 75.47         -- https://ws.nesdev.org/wiki/Display
def_fps = 60
if orig_def_fps:
    def_fps = orig_def_fps
for targetfps in [orig_def_fps, 50/1.001, 50, 50.0070, 57.5, 59.7275, 60/1.001, 60, 60.0988, 75.47, 90, 120]:
    if not targetfps:
        continue
    warn = ""
    # nearest fps to base on
    greaterfps = [fps for fps in modes.keys() if fps >= targetfps]
    if greaterfps == []:
        basefps = max(modes.keys())
        basemode = modes[basefps]
        clock = None
    else:
        # Trust original clock. If real clock differs, maybe make a whitelist or blacklist here
        basefps = min(greaterfps)
        basemode = modes[basefps]
        clock = basemode['clock']
    hor = basemode['hor'].copy()
    ver = basemode['ver'].copy()
    # Assume original totals are minimal for the panel at this clock
    htotal = sum(hor)
    vtotal = sum(ver)
    perfectclock = targetfps*htotal*vtotal/1000
    if not clock:
        warn = "(CAN FAIL) "
        # This may fail, but worth trying. Round up to 10kHz
        clock = math.ceil(perfectclock/10)*10
    elif clock > 1.25*perfectclock:
        # Too much deviation may cause no image
        clock = math.ceil(perfectclock/10)*10

    maxvtotal = round(vtotal*1.25)
    # A little bruteforce to find a best totals for target fps
    # TODO: maybe iterate over some clock values too
    options = [(absfrac(c*1000/targetfps/vt), c, vt)
            for vt in range(vtotal, maxvtotal+1)
            for c in range(clock, round(1.25*perfectclock), 10)
            if ((c*1000/targetfps/vt) >= htotal) and ((c*1000/targetfps/vt) < htotal*1.05) ]
    if options == []:
        acc += [f"# failed to find mode for fps={targetfps:.6f} c={clock} h={htotal} v={vtotal}"]
        continue
    (mindev, newclock, newvtotal) = min(options)
    # construct a new mode with chosen vtotal
    newhtotal = round(newclock*1000/targetfps/newvtotal)
    addhtotal = newhtotal - htotal
    addvtotal = newvtotal - vtotal
    expectedfps = newclock*1000/newvtotal/newhtotal
    hor[2] += addhtotal
    ver[2] += addvtotal
    hor_str = ','.join(map(str, hor))
    ver_str = ','.join(map(str, ver))
    maybe_default = " default=1" if targetfps == def_fps else ""
    acc += [f"M clock={newclock} horizontal={hor_str} vertical={ver_str}{maybe_default} # {warn}fps={expectedfps:.6f} (target={targetfps:.6f})"]

acc += [""]

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
    acc += [f"I seq={data.hex()}{maybe_wait} # orig_cmd=0x{cmd:x}"]

if args.dtbo:
    # remove empty lines as pyfdt does not like them
    acc = [ l for l in acc if l != '']
    # create an overlay tree
    overlay = fdt.FDT()
    overlay.set_property('target-path', '/dsi@ff450000/panel@0', path='fragment@0')
    overlay.set_property('compatible', 'rocknix,generic-dsi', path='fragment@0/__overlay__')
    overlay.set_property('panel_description', acc, path='fragment@0/__overlay__')
    # store the overlay
    with open(args.dtbo, "wb") as f:
        f.write(overlay.to_dtb(version=17))
else:
    for l in acc:
        print(l)
