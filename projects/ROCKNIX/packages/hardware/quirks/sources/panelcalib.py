#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX contributors
#
# Apply a display calibration LUT via wlr-gamma-control-unstable-v1.
# Formula mirrors libretro Image Adjustment (minus saturation, which needs CTM).

from __future__ import annotations

import argparse
import array
import math
import os
import signal
import socket
import struct
import sys
from typing import Callable, Dict, List, Optional, Tuple


WL_DISPLAY_GET_REGISTRY = 1
WL_REGISTRY_BIND = 0
WL_CALLBACK_DONE = 0
WL_REGISTRY_GLOBAL = 0

GAMMA_MANAGER_GET = 0
GAMMA_CONTROL_SET = 0
GAMMA_EVENT_SIZE = 0
GAMMA_EVENT_FAILED = 1

WL_OUTPUT_INTERFACE = "wl_output"
GAMMA_MANAGER_INTERFACE = "zwlr_gamma_control_manager_v1"


class WaylandError(RuntimeError):
    pass


class WaylandClient:
    def __init__(self, display: Optional[str] = None) -> None:
        runtime = os.environ.get("XDG_RUNTIME_DIR", "/var/run/0-runtime-dir")
        name = display or os.environ.get("WAYLAND_DISPLAY", "wayland-1")
        path = name if name.startswith("/") else os.path.join(runtime, name)
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM, 0)
        self.sock.connect(path)
        self.next_id = 2  # 1 is wl_display
        self.objects: Dict[int, str] = {1: "wl_display"}
        self.handlers: Dict[int, Callable[[int, bytes], None]] = {}
        self.globals: Dict[str, Tuple[int, int]] = {}
        self._fd_queue: List[int] = []

    def alloc(self, iface: str) -> int:
        oid = self.next_id
        self.next_id += 1
        self.objects[oid] = iface
        return oid

    def send(self, obj: int, opcode: int, payload: bytes = b"", fds: Optional[List[int]] = None) -> None:
        size = 8 + len(payload)
        header = struct.pack("IHH", obj, opcode, size)
        if fds:
            self.sock.sendmsg([header + payload], [(socket.SOL_SOCKET, socket.SCM_RIGHTS, array.array("i", fds))])
        else:
            self.sock.sendall(header + payload)

    def flush_once(self) -> bool:
        try:
            data, ancdata, _flags, _addr = self.sock.recvmsg(4096, socket.CMSG_SPACE(4 * 28))
        except BlockingIOError:
            return False
        if not data:
            raise WaylandError("wayland display closed")
        for level, typ, cmsg in ancdata:
            if level == socket.SOL_SOCKET and typ == socket.SCM_RIGHTS:
                fds = array.array("i")
                fds.frombytes(cmsg[: len(cmsg) - (len(cmsg) % fds.itemsize)])
                self._fd_queue.extend(fds.tolist())
        offset = 0
        while offset + 8 <= len(data):
            obj, opcode, size = struct.unpack_from("IHH", data, offset)
            body = data[offset + 8 : offset + size]
            offset += size
            handler = self.handlers.get(obj)
            if handler:
                handler(opcode, body)
        return True

    def roundtrip(self) -> None:
        cb = self.alloc("wl_callback")
        done = {"ok": False}

        def on_cb(opcode: int, _body: bytes) -> None:
            if opcode == WL_CALLBACK_DONE:
                done["ok"] = True

        self.handlers[cb] = on_cb
        self.send(1, 0, struct.pack("I", cb))  # wl_display.sync
        while not done["ok"]:
            self.flush_once()


def pack_string(s: str) -> bytes:
    b = s.encode("utf-8") + b"\x00"
    padded = (len(b) + 3) & ~3
    return struct.pack("I", len(b)) + b.ljust(padded, b"\x00")


def clamp01(v: float) -> float:
    if v < 0.0:
        return 0.0
    if v > 1.0:
        return 1.0
    return v


def sample_channel(
    x: float,
    *,
    target_gamma: float,
    monitor_gamma: float,
    contrast: float,
    black_level: float,
    bright_boost: float,
    gain: float,
) -> float:
    # Image Adjustment fragment path without saturation/luminance/HSV.
    y = (x - 0.5) * contrast + 0.5 + bright_boost
    y = y - black_level
    denom = 1.0 - black_level
    if denom != 0.0:
        y = y / denom
    y = clamp01(y)
    # shader: gamma = monitor/target; pow(y, 1/gamma) == pow(y, target/monitor)
    if y > 0.0:
        y = math.pow(y, target_gamma / monitor_gamma)
    y = clamp01(y * gain)
    return y


def build_ramps(
    size: int,
    *,
    target_gamma: float,
    monitor_gamma: float,
    contrast: float,
    black_level: float,
    bright_boost: float,
    red: float,
    green: float,
    blue: float,
) -> bytes:
    if size < 2:
        raise WaylandError(f"invalid gamma size {size}")
    ramps = array.array("H")
    for gain in (red, green, blue):
        for i in range(size):
            x = i / (size - 1)
            y = sample_channel(
                x,
                target_gamma=target_gamma,
                monitor_gamma=monitor_gamma,
                contrast=contrast,
                black_level=black_level,
                bright_boost=bright_boost,
                gain=gain,
            )
            ramps.append(int(round(y * 65535.0)))
    return ramps.tobytes()


def apply_gamma(args: argparse.Namespace) -> None:
    wl = WaylandClient(args.display)

    def on_registry(opcode: int, body: bytes) -> None:
        if opcode != WL_REGISTRY_GLOBAL:
            return
        name, = struct.unpack_from("I", body, 0)
        iface_len, = struct.unpack_from("I", body, 4)
        iface = body[8 : 8 + iface_len - 1].decode("utf-8")
        padded = (iface_len + 3) & ~3
        version, = struct.unpack_from("I", body, 8 + padded)
        wl.globals[iface] = (name, version)

    registry = wl.alloc("wl_registry")
    wl.handlers[registry] = on_registry
    wl.send(1, WL_DISPLAY_GET_REGISTRY, struct.pack("I", registry))
    wl.roundtrip()

    if GAMMA_MANAGER_INTERFACE not in wl.globals:
        raise WaylandError(f"compositor lacks {GAMMA_MANAGER_INTERFACE}")
    if WL_OUTPUT_INTERFACE not in wl.globals:
        raise WaylandError("no wl_output globals")

    # Bind all outputs; gamma manager once.
    mgr_name, mgr_ver = wl.globals[GAMMA_MANAGER_INTERFACE]
    mgr = wl.alloc(GAMMA_MANAGER_INTERFACE)
    wl.send(
        registry,
        WL_REGISTRY_BIND,
        struct.pack("I", mgr_name) + pack_string(GAMMA_MANAGER_INTERFACE) + struct.pack("II", min(mgr_ver, 1), mgr),
    )

    # Re-scan registry: wl.globals keeps only the last name per interface.
    output_globals: List[Tuple[int, int]] = []

    def on_registry2(opcode: int, body: bytes) -> None:
        if opcode != WL_REGISTRY_GLOBAL:
            return
        name, = struct.unpack_from("I", body, 0)
        iface_len, = struct.unpack_from("I", body, 4)
        iface = body[8 : 8 + iface_len - 1].decode("utf-8")
        padded = (iface_len + 3) & ~3
        version, = struct.unpack_from("I", body, 8 + padded)
        if iface == WL_OUTPUT_INTERFACE:
            output_globals.append((name, version))

    registry2 = wl.alloc("wl_registry")
    wl.handlers[registry2] = on_registry2
    wl.send(1, WL_DISPLAY_GET_REGISTRY, struct.pack("I", registry2))
    wl.roundtrip()

    if not output_globals:
        raise WaylandError("no outputs advertised")

    outputs: List[int] = []
    for name, version in output_globals:
        out = wl.alloc(WL_OUTPUT_INTERFACE)
        wl.send(
            registry2,
            WL_REGISTRY_BIND,
            struct.pack("I", name) + pack_string(WL_OUTPUT_INTERFACE) + struct.pack("II", min(version, 4), out),
        )
        outputs.append(out)

    controls: List[int] = []
    sizes: Dict[int, int] = {}
    failed: Dict[int, bool] = {}

    def make_control_handler(cid: int):
        def handler(opcode: int, body: bytes) -> None:
            if opcode == GAMMA_EVENT_SIZE:
                (size,) = struct.unpack_from("I", body, 0)
                sizes[cid] = size
            elif opcode == GAMMA_EVENT_FAILED:
                failed[cid] = True

        return handler

    for out in outputs:
        cid = wl.alloc("zwlr_gamma_control_v1")
        wl.handlers[cid] = make_control_handler(cid)
        wl.send(mgr, GAMMA_MANAGER_GET, struct.pack("II", cid, out))
        controls.append(cid)

    # Collect gamma_size events.
    while len(sizes) + sum(1 for c in controls if failed.get(c)) < len(controls):
        wl.flush_once()

    applied = 0
    for cid in controls:
        if failed.get(cid):
            print(f"panelcalib: gamma control {cid} failed", file=sys.stderr)
            continue
        size = sizes.get(cid)
        if not size:
            print(f"panelcalib: no gamma size for {cid}", file=sys.stderr)
            continue
        blob = build_ramps(
            size,
            target_gamma=args.target_gamma,
            monitor_gamma=args.monitor_gamma,
            contrast=args.contrast,
            black_level=args.black_level,
            bright_boost=args.bright_boost,
            red=args.red,
            green=args.green,
            blue=args.blue,
        )
        fd = os.memfd_create("panelcalib-gamma", 0)
        try:
            os.write(fd, blob)
            os.lseek(fd, 0, os.SEEK_SET)
            wl.send(cid, GAMMA_CONTROL_SET, b"", fds=[fd])
            wl.roundtrip()
        finally:
            os.close(fd)
        applied += 1

    if applied == 0:
        raise WaylandError("failed to apply gamma on any output")

    print(
        "panelcalib: applied "
        f"target={args.target_gamma} monitor={args.monitor_gamma} "
        f"contrast={args.contrast} black={args.black_level} "
        f"rgb=({args.red},{args.green},{args.blue}) on {applied} output(s)",
        flush=True,
    )

    if args.once:
        return

    # Keep process alive; destroying the gamma object restores identity LUT.
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    signal.signal(signal.SIGINT, lambda *_: sys.exit(0))
    wl.sock.setblocking(True)
    while True:
        wl.flush_once()


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    p = argparse.ArgumentParser(description="ROCKNIX panel calibration via wlr-gamma-control")
    p.add_argument("--display", default=None, help="WAYLAND_DISPLAY override")
    p.add_argument("--once", action="store_true", help="apply and exit (LUT may reset)")
    p.add_argument("--target-gamma", type=float, default=2.50)
    p.add_argument("--monitor-gamma", type=float, default=1.70)
    p.add_argument("--contrast", type=float, default=1.10)
    p.add_argument("--black-level", type=float, default=-0.15)
    p.add_argument("--bright-boost", type=float, default=0.0)
    p.add_argument("--red", type=float, default=1.05)
    p.add_argument("--green", type=float, default=1.0)
    p.add_argument("--blue", type=float, default=0.95)
    return p.parse_args(argv)


def main() -> int:
    args = parse_args()
    try:
        apply_gamma(args)
    except Exception as exc:  # noqa: BLE001 - top-level service entry
        print(f"panelcalib: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
