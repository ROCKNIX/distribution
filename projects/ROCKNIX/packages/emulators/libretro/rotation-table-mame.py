#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)
#
# rotation-table-mame.py [--min N] <core source root> <drivers dir, relative to the root>
#
# The quarter turns a MAME-family libretro core asks the display for, per
# game, read from the GAME() macros in its drivers. The cores map a plain
# ROT270 to 1, ROT180 to 2 and ROT90 to 3 (mame2003-plus src/mame2003/video.c,
# mame2010 src/osd/retro/retromain.c); a driver whose orientation combines a
# rotation with a flip is rotated by the core itself and gets no turn here.
#
# Prints "<romname> <turns>" for every game with a turn, sorted, and the
# count on stderr. With --min N it fails when fewer than N games have a
# turn: a drivers directory with no macros in it is a wrong path, not a
# smaller core. Only what the compiler reads counts: a GAME() inside /* */,
# after //, inside a string, or in an arm the preprocessor never compiles
# (an #if 0 or #elif 0, or an #elif or #else after an #if 1 or #elif 1 that
# was taken) is not read -- any other condition depends on the build's
# defines and is read as live -- and every live declaration counts, so a
# game declared ROT0 has no turn whatever a commented-out line said.
import os, re, sys

LEXEME = re.compile(r'//[^\n]*|/\*.*?(?:\*/|\Z)|"(?:\\.|[^"\\\n])*"|\'(?:\\.|[^\'\\\n])*\'|(?<!\w)\.?[0-9](?:[eEpP][+-]|\'\w|[\w.])*', re.S)
DIRECTIVE = re.compile(r'\s*#\s*(ifdef|ifndef|if|elifdef|elifndef|elif|else|endif)\b(.*)')
KNOWN = {'0': 'no', '1': 'yes'}   # the only conditions read without the build's defines
TURNS = {'ROT270': 1, 'ROT180': 2, 'ROT90': 3, 'ROT0': 0}


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
    if len(argv) != 2:
        sys.exit('usage: rotation-table-mame.py [--min N] <core source root> <drivers dir>')
    root, drivers = argv
    out = {}
    for dirpath, _, files in os.walk(os.path.join(root, drivers)):
        for f in sorted(files):
            if not (f.endswith('.c') or f.endswith('.cpp')):
                continue
            with open(os.path.join(dirpath, f), errors='replace') as fh:
                # strings blanked as well: a GAME( inside one is text, and a
                # title's commas and parentheses do not split the macro
                text = blank_strings(drop_dead(strip_comments(fh.read())))
            # a macro spans lines: read to its closing parenthesis
            for m in re.finditer(r'\bGAME[A-Z]*\s*\(', text):
                start = m.end(); depth = 1; i = start
                while i < len(text) and depth:
                    if text[i] == '(':
                        depth += 1
                    elif text[i] == ')':
                        depth -= 1
                    i += 1
                args = [a.strip() for a in text[start:i - 1].split(',')]
                if len(args) < 7:
                    continue
                name = args[1]
                rot = next((a for a in args if a.startswith('ROT')), None)
                if rot is None or not re.fullmatch(r'[a-z0-9_]+', name):
                    continue
                # a combination such as "ROT90 | ORIENTATION_FLIP_X" is not in the map: no turn
                out[name] = TURNS.get(rot.replace(' ', ''), 0)
    rows = sorted(k for k in out if out[k])
    for k in rows:
        print(k, out[k])
    print('# %d games with a turn' % len(rows), file=sys.stderr)
    if len(rows) < minimum:
        sys.exit('rotation-table-mame.py: %d games with a turn, under the %d a real source tree has -- '
                 'check the source root and drivers directory handed to it' % (len(rows), minimum))


if __name__ == '__main__':
    main(sys.argv[1:])
