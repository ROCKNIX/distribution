# sing-box (ROCKNIX package)

[sing-box](https://sing-box.sagernet.org/) — universal proxy platform. Provides an
obfuscation-capable client (VLESS/Reality, AmneziaWG, WireGuard, Shadowsocks,
Hysteria2, TUIC) with a `tun` transparent-routing mode, so the whole device can
route through a censorship-resistant tunnel where plain WireGuard is DPI-blocked.

Integrated like `tailscale`/`zerotier-one`:

* binary installed to `/usr/sbin/sing-box`
* started by the autostart daemon `004-sing-box` when the setting `singbox.up` is `1`
* systemd unit `sing-box.service`

## Configuration

Place your config at:

```
/storage/.config/sing-box/config.json
```

A template ships at `/usr/config/sing-box/config.json.sample` (copied to
`/storage/.config/sing-box/` on first boot). Fill in your provider's values
(server, uuid, Reality public key / short id, SNI, gRPC service name), then
enable the **sing-box** toggle in *Network Settings* (or `set_setting singbox.up 1`).

Validate a config before enabling:

```
sing-box check -c /storage/.config/sing-box/config.json
```
