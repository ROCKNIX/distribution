#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)
#
# rotation-table-fba.py [--min N] <core source root>
#
# The quarter turns an FBA-family libretro core (fbneo, fbalpha2012,
# fbalpha2019) asks the display for, per game, read from the BurnDriver
# tables under <root>/src/burn/drv. The three cores' libretro.cpp map the
# driver flags the same way with the "Vertical mode" option off:
# BDF_ORIENTATION_VERTICAL -> 1, BDF_ORIENTATION_FLIPPED -> 2, both -> 3.
#
# Prints "<romname> <turns>" for every driver whose turn is not 0, sorted,
# and the count on stderr. With --min N it fails when fewer than N games
# have a turn: a source root with no drivers under it is a wrong path, not
# a smaller core. Only what the compiler reads counts: a driver or a flag
# inside /* */, after //, or in an arm the preprocessor never compiles (an
# #if 0 or #elif 0, or an #elif or #else after an #if 1 or #elif 1 that was
# taken) is not read -- any other condition depends on the build's defines
# and is read as live -- and a driver's end and its flags are read outside
# its strings, never from their text. A BurnDriverD (a debug build's driver,
# left out of a release core's driver list) is read like any other, so its
# row names a game the release core does not offer.
import os, re, sys

LEXEME = re.compile(r'//[^\n]*|/\*.*?(?:\*/|\Z)|"(?:\\.|[^"\\\n])*"|\'(?:\\.|[^\'\\\n])*\'|(?<!\w)\.?[0-9](?:[eEpP][+-]|\'\w|[\w.])*', re.S)
STRING = re.compile(r'"(?:\\.|[^"\\\n])*"')
DIRECTIVE = re.compile(r'\s*#\s*(ifdef|ifndef|if|elifdef|elifndef|elif|else|endif)\b(.*)')
KNOWN = {'0': 'no', '1': 'yes'}   # the only conditions read without the build's defines
DRIVER = re.compile(r'struct\s+BurnDriver[D]?\s+BurnDrv\w+\s*=\s*\{(.*?)\};', re.S)


def strip_comments(text):
    """The source with its comments blanked, literals kept (a block comment
    keeps its newlines, so nothing after it moves line). A number is read
    whole, the way the preprocessor reads one, so a quote inside it is a
    C++14 digit separator (1'000, 0xFF'00), not a character literal; any
    other quote opens one."""
    return LEXEME.sub(lambda m: (' ' + '\n' * m.group(0).count('\n')) if m.group(0)[0] == '/' else m.group(0), text)


def blank_strings(text):
    """The text with the inside of every string literal blanked and every
    offset kept. Read with the same lexer, so the quote in a character
    literal ('"') opens no string. Run after strip_comments."""
    return LEXEME.sub(lambda m: ('"' + ' ' * (len(m.group(0)) - 2) + '"') if m.group(0)[0] == '"' else m.group(0), text)


def drop_dead(text):
    """The source with what the preprocessor never compiles blanked. A
    literal 0 or 1 is known, in an #elif as in an #if: an arm whose
    condition is 0 is blanked, and so is every #elif and #else arm after
    one known to be taken (#if 1, or #elif 1 after arms known not to be).
    Any other condition depends on the build's defines, which are not known
    here, and its arm is read as live; an arm after it is blanked only when
    its own condition is 0 or an arm between is known to be taken."""
    out = []
    # one [arm, taken] pair per open #if, each 'yes', 'no' or 'maybe': is the
    # current arm compiled, and has it or an arm before it been. A line is
    # blanked while any open #if's current arm is 'no'.
    stack = []
    for line in text.split('\n'):
        d = DIRECTIVE.match(line)
        if d:
            kind, rest = d.group(1), d.group(2).strip()
            cond = KNOWN.get(rest, 'maybe') if kind in ('if', 'elif') else 'yes' if kind == 'else' else 'maybe'
            if kind in ('if', 'ifdef', 'ifndef'):
                stack.append([cond, cond])
            elif kind == 'endif':
                if stack:
                    stack.pop()
            elif stack:   # #elif, #elifdef, #elifndef, #else
                taken = stack[-1][1]
                arm = 'no' if taken == 'yes' or cond == 'no' else cond if taken == 'no' else 'maybe'
                taken = 'yes' if 'yes' in (taken, cond) else 'no' if taken == cond == 'no' else 'maybe'
                stack[-1] = [arm, taken]
            out.append('')
            continue
        out.append('' if any(arm == 'no' for arm, _ in stack) else line)
    return '\n'.join(out)


def main(argv):
    minimum = 0
    if len(argv) >= 2 and argv[0] == '--min':
        minimum = int(argv[1])
        argv = argv[2:]
    if len(argv) != 1:
        sys.exit('usage: rotation-table-fba.py [--min N] <core source root>')
    out = {}
    for dirpath, _, files in os.walk(os.path.join(argv[0], 'src', 'burn', 'drv')):
        for f in sorted(files):
            if not f.endswith('.cpp'):
                continue
            with open(os.path.join(dirpath, f), errors='replace') as fh:
                text = drop_dead(strip_comments(fh.read()))
            # a driver ends at the first }; outside its strings (a }; in a
            # title is text): matched in the blanked text, its name read
            # from the source at the same offsets
            blanked = blank_strings(text)
            for m in DRIVER.finditer(blanked):
                name = STRING.search(text, m.start(1), m.end(1))
                if not name:
                    continue
                fields = blanked[m.start(1):m.end(1)]
                vertical = re.search(r'\bBDF_ORIENTATION_VERTICAL\b', fields) is not None
                flipped = re.search(r'\bBDF_ORIENTATION_FLIPPED\b', fields) is not None
                turns = 3 if (vertical and flipped) else 1 if vertical else 2 if flipped else 0
                out[name.group(0)[1:-1]] = turns
    rows = sorted(k for k in out if out[k])
    for k in rows:
        print(k, out[k])
    print('# %d games with a turn' % len(rows), file=sys.stderr)
    if len(rows) < minimum:
        sys.exit('rotation-table-fba.py: %d games with a turn, under the %d a real source tree has -- '
                 'check the source root handed to it' % (len(rows), minimum))


if __name__ == '__main__':
    main(sys.argv[1:])
