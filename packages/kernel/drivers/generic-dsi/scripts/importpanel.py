#!/usr/bin/env python

# https://pypi.org/project/fdt/
# pip install fdt

import sys, argparse
import fdt
import math

parser = argparse.ArgumentParser(description="Extract MIPI panel description from stock dtb to use with panel-mipi-generic driver")
parser.add_argument("-n", "--name", help="human readable panel name")
parser.add_argument("-O", "--out-format", help="output format", choices=['dts', 'dtbo', 'pdesc'], default='pdesc', dest='outfmt')
parser.add_argument("-o", "--out", help="output file")
parser.add_argument("-D", "--diagonal", help="panel size (diagonal), inches; used to calculate physical size when dtb lacks it", type=float)
parser.add_argument(metavar="/path/to/vendor.dtb", dest="source_dtb", help="dtb file from stock firmware")
args = parser.parse_args()
comment = (args.outfmt == 'pdesc')

with open(args.source_dtb, "rb") as f:
    dtb_data = f.read()

acc = []

g_name = f"name='{args.name}' " if args.name else ""

dt = fdt.parse_dtb(dtb_data)
for target in ["dsi@ff450000/panel@0", "dsi@fe060000/panel@0"]:
    try:
        panel = dt.get_node(target)
        break
    except:
        pass


def prop_default(prop, default):
    try:
        return panel.get_property(prop).value
    except:
        return default

delays = [
        prop_default("prepare-delay-ms", 50),
        prop_default("reset-delay-ms", 50),
        prop_default("init-delay-ms", 50),
        prop_default("enable-delay-ms", 50),
        20  # ready -- no such timeout in legacy dtbs
        ]
delays_str = ','.join(map(str, delays))

fmt = ['rgb888', 'rgb666', 'rgb666_packed', 'rgb565'] [panel.get_property("dsi,format").value]
lanes = panel.get_property("dsi,lanes").value
flags = panel.get_property("dsi,flags").value
flags |= 0x0400


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


try:
    w = panel.get_property("width-mm").value
    h = panel.get_property("height-mm").value
except:
    if not args.diagonal:
        sys.stderr.buffer.write(b'width-mm or height-mm not set, specify diagonal with -D option\n')
        exit(1)
    randmode = list(modes.values())[0]
    hactive = randmode['hor'][0]
    vactive = randmode['ver'][0]
    pxdiag = math.sqrt(hactive*hactive + vactive*vactive)
    diag_mm = args.diagonal * 25.4
    w = round(diag_mm * hactive/pxdiag)
    h = round(diag_mm * vactive/pxdiag)

# G size=52,70 delays=2,1,20,120,50,20 format=rgb888 lanes=4 flags=0xe03
acc += [f"G {g_name}size={w},{h} delays={delays_str} format={fmt} lanes={lanes} flags=0x{flags:x}", ""]

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
common_fpss = [50/1.001, 50, 50.0070, 57.5, 59.7275, 60/1.001, 60, 60.0988, 75.47, 90, 120];
common_fpss = [ fps for fps in common_fpss if fps != orig_def_fps]
for targetfps in [orig_def_fps] + common_fpss:
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
    maybe_comment = f" # {warn}fps={expectedfps:.6f} (target={targetfps:.6f})" if comment else ""
    acc += [f"M clock={newclock} horizontal={hor_str} vertical={ver_str}{maybe_default}{maybe_comment}"]

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
    maybe_comment = f" # orig_cmd=0x{cmd:x}" if comment else ""
    acc += [f"I seq={data.hex()}{maybe_wait}{maybe_comment}"]


# pre-formatted dts parts
dts_header = f"""/dts-v1/;
// version: 17
// last_comp_version: 16

/ {{
    fragment@0 {{
        target-path = "/{target}";
        __overlay__ {{
            compatible = "rocknix,generic-dsi";
            panel_description ="""
dts_footer = """;
        };
    };
};
"""

# choose where to output
if args.out:
    f = open(args.out, "wb")
else:
    f = sys.stdout.buffer

# Helper for short cmd grouping
def cmd_prefix(line):
    if len(line) != 10:
        return None
    if line[0:6] != 'I seq=':
        return None
    # "I seq=0320"   ->  "0l"
    return line[6:7] + ('l' if line[7] < '8' else 'H')
    
if args.outfmt == 'dts':
    # For fancy multi-line format we do not use fdt.FDT.to_dts(), but craft custom dts
    f.write(dts_header.encode())
    prevpfx = None;
    nocomma = True
    for l in acc:
        comma = '' if nocomma else ','

        curpfx = cmd_prefix(l)
        if curpfx and curpfx == prevpfx:
            delimiter = ' '
        else:
            delimiter = '\n                '
        prevpfx = curpfx

        if l == '':
            f.write((comma + '\n').encode())
            nocomma = True
        else:
            f.write((comma + delimiter + '"' + l + '"').encode())
            nocomma = False

    f.write(dts_footer.encode())
elif args.outfmt == 'dtbo':
    # remove empty lines as pyfdt does not like them
    acc = [ l for l in acc if l != '']
    # create an overlay tree
    overlay = fdt.FDT()
    overlay.header.version = 17
    overlay.set_property('target-path', '/'+target, path='fragment@0')
    overlay.set_property('compatible', 'rocknix,generic-dsi', path='fragment@0/__overlay__')
    overlay.set_property('panel_description', acc, path='fragment@0/__overlay__')
    # send the overlay to output
    f.write(overlay.to_dtb())
else:
    for l in acc:
        f.write((l + "\n").encode())

if args.out:
    f.close()
