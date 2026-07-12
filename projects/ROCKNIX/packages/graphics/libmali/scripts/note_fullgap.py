#!/usr/bin/env python3
# Patch PT_NOTE to PT_LOAD to map the gap between the executable segment
import struct, sys

PAGE = 0x1000
PT_LOAD, PT_NOTE = 1, 4
PF_R, PF_X = 4, 1

f = open(sys.argv[1], "r+b")
d = bytearray(f.read())
assert d[:4] == b"\x7fELF" and d[4] == 1 and d[5] == 1, "want ELF32 LE"

phoff  = struct.unpack_from("<I", d, 0x1C)[0]
phsize = struct.unpack_from("<H", d, 0x2A)[0]
phnum  = struct.unpack_from("<H", d, 0x2C)[0]

exec_end = note = None
loads = []
for i in range(phnum):
    o = phoff + i * phsize
    t, off, va, pa, fsz, msz, fl = struct.unpack_from("<7I", d, o)
    if t == PT_LOAD:
        loads.append(va)
        if fl & PF_X:
            exec_end = va + msz
    elif t == PT_NOTE and note is None:
        note = o

assert exec_end and note, "no exec LOAD and no PT_NOTE"

guard = (exec_end + PAGE - 1) & ~(PAGE - 1)
nxt = min(v for v in loads if v > guard)
size = (nxt & ~(PAGE - 1)) - guard
assert 0 < size <= 0x200000, "gap size looks wrong: %#x" % size

if guard in loads:
    print("already patched")
    sys.exit()

struct.pack_into("<7I", d, note, PT_LOAD, guard, guard, guard, size, size, PF_R)
struct.pack_into("<I", d, note + 28, PAGE)

f.seek(0)
f.write(d)
f.close()
print("mapped gap %#x..%#x R" % (guard, guard + size))
