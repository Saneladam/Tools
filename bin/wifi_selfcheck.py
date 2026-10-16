#!/usr/bin/env python3
"""
wifi_selfcheck.py — auditoría DEFENSIVA de TU WiFi / LAN casera (solo lectura).

Pensado para casa: interfaz WiFi, cifrado, gateway, DNS, vecinos conocidos,
y (opcional) inventario suave de la subnet local.

NO hace: escaneo de redes ajenas, exploits, fuerza bruta del router, ni
ataques. No lo ejecutes fuera de una red que administras.

Uso:
  python3 ~/wifi_selfcheck.py           # checks locales + vecinos ARP cache
  python3 ~/wifi_selfcheck.py --deep    # + arp-scan / ping-sweep suave de TU /24
  python3 ~/wifi_selfcheck.py --no-color

Por defecto NO se lanza --deep. En casa, tú decides cuándo correrlo.
"""
from __future__ import annotations

import argparse
import ipaddress
import os
import re
import shutil
import socket
import subprocess
import sys
from pathlib import Path

OK, WARN, FAIL, INFO = "OK", "WARN", "FAIL", "INFO"
findings: list[tuple[str, str, str]] = []
USE_COLOR = True


def add(level: str, title: str, detail: str = "") -> None:
    findings.append((level, title, detail))


def run(cmd: list[str], timeout: float = 15.0) -> tuple[int, str, str]:
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout, check=False)
        return p.returncode, p.stdout.strip(), p.stderr.strip()
    except FileNotFoundError:
        return 127, "", f"no está: {cmd[0]}"
    except subprocess.TimeoutExpired:
        return 124, "", "timeout"


def section(title: str) -> None:
    print(f"\n== {title} ==")


def _color(level: str) -> str:
    if not USE_COLOR or not sys.stdout.isatty():
        return ""
    return {
        OK: "\033[1;32m",
        WARN: "\033[1;33m",
        FAIL: "\033[1;31m",
        INFO: "\033[1;36m",
    }.get(level, "")


def _reset() -> str:
    return "\033[0m" if USE_COLOR and sys.stdout.isatty() else ""


def wifi_iface() -> str | None:
    code, out, _ = run(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "dev"])
    if code == 0 and out:
        for ln in out.splitlines():
            parts = ln.split(":")
            if len(parts) >= 3 and parts[1] == "wifi" and "connected" in parts[2]:
                return parts[0]
    code, out, _ = run(["iw", "dev"])
    if code == 0:
        m = re.search(r"Interface\s+(\S+)", out)
        if m:
            return m.group(1)
    return None


def check_link(iface: str) -> dict:
    section(f"Enlace WiFi ({iface})")
    info: dict = {"iface": iface}
    code, out, err = run(["iw", "dev", iface, "link"])
    print(out or err or "(sin iw link)")
    ssid = None
    m = re.search(r"SSID:\s*(.+)", out)
    if m:
        ssid = m.group(1).strip()
        info["ssid"] = ssid
        add(INFO, "SSID conectado", ssid)
    else:
        add(WARN, "Sin SSID en iw link", "¿desconectado?")
    m = re.search(r"freq:\s*(\d+)", out)
    if m:
        info["freq"] = m.group(1)
        add(INFO, "Frecuencia MHz", m.group(1))
    m = re.search(r"signal:\s*([-0-9]+)\s*dBm", out)
    if m:
        sig = int(m.group(1))
        info["signal"] = sig
        if sig >= -55:
            add(OK, "Señal fuerte", f"{sig} dBm")
        elif sig >= -70:
            add(INFO, "Señal media", f"{sig} dBm")
        else:
            add(WARN, "Señal débil", f"{sig} dBm")
    # nmcli security
    code, out, _ = run(
        ["nmcli", "-t", "-f", "GENERAL.CONNECTION,GENERAL.DEVICE", "dev", "show", iface]
    )
    conn = None
    for ln in out.splitlines():
        if ln.startswith("GENERAL.CONNECTION:"):
            conn = ln.split(":", 1)[1].strip()
    if conn and conn != "--":
        info["connection"] = conn
        code, out, _ = run(["nmcli", "-t", "-f", "802-11-wireless-security.key-mgmt,802-11-wireless-security.proto,802-11-wireless.mode", "con", "show", conn])
        print(out or "(sin detalle nmcli security)")
        km = ""
        for ln in out.splitlines():
            if "key-mgmt" in ln:
                km = ln.split(":", 1)[-1].strip().lower()
        info["key_mgmt"] = km
        if "sae" in km or "wpa3" in km:
            add(OK, "Cifrado WPA3/SAE", km)
        elif "wpa-psk" in km or "wpa2" in km:
            add(OK, "Cifrado WPA2-PSK", km)
        elif "wep" in km:
            add(FAIL, "WEP inseguro", km)
        elif "none" in km or km == "":
            add(WARN, "key-mgmt vacío o abierto", km or "revisa a mano")
        else:
            add(INFO, "key-mgmt", km)
    return info


def check_addrs(iface: str) -> dict:
    section("Direcciones IP")
    info: dict = {}
    code, out, _ = run(["ip", "-4", "-o", "addr", "show", "dev", iface])
    print(out or "(sin IPv4)")
    cidr = None
    m = re.search(r"inet\s+(\d+\.\d+\.\d+\.\d+/\d+)", out)
    if m:
        cidr = m.group(1)
        info["cidr"] = cidr
        add(INFO, "IPv4", cidr)
        try:
            net = ipaddress.ip_interface(cidr).network
            info["network"] = str(net)
            if net.num_addresses > 256:
                add(INFO, "Red amplia", str(net))
            else:
                add(INFO, "Red local /24 típica", str(net))
        except ValueError:
            pass
    else:
        add(WARN, "Sin IPv4 en la WiFi", iface)
    code, out, _ = run(["ip", "-4", "route", "show", "default"])
    print(out or "(sin default route)")
    m = re.search(r"default via (\d+\.\d+\.\d+\.\d+)", out)
    if m:
        gw = m.group(1)
        info["gateway"] = gw
        add(INFO, "Gateway", gw)
        # ping gateway once
        c, _, _ = run(["ping", "-c", "1", "-W", "2", gw], timeout=5)
        if c == 0:
            add(OK, "Gateway responde a ping", gw)
        else:
            add(WARN, "Gateway no responde a ping", gw)
    else:
        add(WARN, "Sin ruta por defecto", "")
    return info


def check_dns() -> None:
    section("DNS")
    resolv = Path("/etc/resolv.conf")
    if not resolv.exists():
        add(INFO, "Sin resolv.conf", "")
        return
    text = resolv.read_text(errors="replace")
    ns = [ln.split()[1] for ln in text.splitlines() if ln.strip().startswith("nameserver")]
    print("\n".join(ns) or "(ninguno)")
    if not ns:
        add(WARN, "Sin nameservers", "")
        return
    add(INFO, f"{len(ns)} nameserver(s)", ", ".join(ns[:4]))
    # router-as-DNS vs public
    private = []
    public = []
    for n in ns:
        try:
            ip = ipaddress.ip_address(n)
            (private if ip.is_private else public).append(n)
        except ValueError:
            public.append(n)
    if private:
        add(INFO, "DNS en LAN (router/pihole?)", ", ".join(private))
    if public:
        add(INFO, "DNS público", ", ".join(public))


def check_neigh(iface: str) -> None:
    section("Vecinos (tabla ARP/neigh, pasivo)")
    code, out, err = run(["ip", "neigh", "show", "dev", iface])
    lines = [ln for ln in (out or "").splitlines() if ln.strip()]
    print("\n".join(lines[:40]) or "(vacía)")
    if len(lines) > 40:
        print(f"  … +{len(lines)-40}")
    reachable = [ln for ln in lines if "REACHABLE" in ln or "DELAY" in ln or "STALE" in ln]
    add(INFO, f"Entradas neigh: {len(lines)}", f"activas~{len(reachable)}")
    # flag many unknowns as info only
    if len(lines) >= 15:
        add(INFO, "Muchos vecinos en cache", "normal en WiFi doméstica ocupada")


def check_deep(network: str | None, gateway: str | None) -> None:
    section("Inventario profundo (TU subnet)")
    if not network:
        add(WARN, "--deep sin red IPv4 conocida", "omitido")
        return
    add(INFO, "Modo deep sobre", network)
    # Prefer arp-scan if present (needs root often)
    if shutil.which("arp-scan"):
        cmd = ["arp-scan", "--localnet", "--quiet"]
        # try without sudo first; if fails, note
        code, out, err = run(cmd, timeout=60)
        if code != 0:
            add(INFO, "arp-scan necesita privilegios", (err or out)[:160])
            print(err or out or "(falló sin root)")
            print("Sugerencia en casa: sudo arp-scan --localnet")
        else:
            hosts = [ln for ln in out.splitlines() if re.search(r"\d+\.\d+\.\d+\.\d+", ln)]
            print("\n".join(hosts[:50]))
            add(INFO, f"arp-scan: {len(hosts)} host(s)", network)
        return
    # fallback: ping sweep limited (slow-ish but defensive inventory of OWN /24)
    try:
        net = ipaddress.ip_network(network, strict=False)
    except ValueError:
        add(WARN, "Red inválida para deep", network)
        return
    if net.num_addresses > 256:
        add(WARN, "Red demasiado grande para sweep", str(net))
        return
    found = []
    # skip network/broadcast
    hosts = list(net.hosts())
    print(f"ping-sweep suave de {len(hosts)} hosts (puede tardar ~1–2 min)…")
    for ip in hosts:
        c, _, _ = run(["ping", "-c", "1", "-W", "1", str(ip)], timeout=3)
        if c == 0:
            found.append(str(ip))
            print(f"  up {ip}")
    add(INFO, f"Hosts que respondieron ping: {len(found)}", ", ".join(found[:12]))
    if gateway and gateway not in found:
        add(WARN, "Gateway no apareció en sweep", gateway)


def check_router_ports(gateway: str | None) -> None:
    """Solo el gateway de TU red: puertos de admin habituales (TCP connect corto)."""
    section("Puertos de admin en el gateway (solo tu router)")
    if not gateway:
        add(INFO, "Sin gateway, omitido", "")
        return
    ports = [80, 443, 22, 23, 8080, 8443]
    open_p = []
    for port in ports:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(1.0)
        try:
            if s.connect_ex((gateway, port)) == 0:
                open_p.append(port)
        finally:
            s.close()
    if not open_p:
        add(INFO, "Ningún puerto admin típico abierto (o filtrado)", gateway)
        print("(ninguno de 80/443/22/23/8080/8443)")
        return
    print("abiertos:", open_p)
    if 23 in open_p:
        add(FAIL, "Telnet abierto en el router", f"{gateway}:23")
    if 80 in open_p and 443 not in open_p:
        add(WARN, "Admin HTTP sin HTTPS visible", f"{gateway}:80")
    if 443 in open_p or 80 in open_p:
        add(INFO, "Interfaz web del router alcanzable", ",".join(map(str, open_p)))
    if 22 in open_p:
        add(INFO, "SSH en el router", f"{gateway}:22")


def summarize() -> int:
    section("Resumen")
    counts = {OK: 0, WARN: 0, FAIL: 0, INFO: 0}
    print(f"{'NIVEL':<6}\t{'hallazgo'}\t{'detalle'}")
    print(f"{'------':<6}\t{'--------'}\t{'-------'}")
    for level, title, detail in findings:
        counts[level] = counts.get(level, 0) + 1
        print(f"{_color(level)}{level:<6}{_reset()}\t{title}\t{detail}")
    parts = [f"{_color(l)}{l}={counts[l]}{_reset()}" for l in (OK, WARN, FAIL, INFO)]
    print("\nTotales:\t" + "\t".join(parts))
    if counts[FAIL]:
        print(f"{_color(FAIL)}Salida: 2 (hay FAIL){_reset()}")
        return 2
    if counts[WARN]:
        print(f"{_color(WARN)}Salida: 1 (hay WARN){_reset()}")
        return 1
    print(f"{_color(OK)}Salida: 0 (limpio){_reset()}")
    return 0


def main() -> int:
    global USE_COLOR
    ap = argparse.ArgumentParser(description="Auditoría defensiva WiFi/LAN propia")
    ap.add_argument("--deep", action="store_true", help="Inventario de TU subnet (arp-scan o ping)")
    ap.add_argument("--no-color", action="store_true")
    ap.add_argument("--skip-router-ports", action="store_true")
    args = ap.parse_args()
    USE_COLOR = not args.no_color

    print("wifi_selfcheck — defensivo, red que TÚ administras")
    print("No ejecutar en redes ajenas. --deep solo en casa.")
    iface = wifi_iface()
    if not iface:
        add(FAIL, "No hay interfaz WiFi conectada", "")
        print("Sin WiFi activa.")
        return summarize()
    link = check_link(iface)
    addrs = check_addrs(iface)
    check_dns()
    check_neigh(iface)
    if not args.skip_router_ports:
        check_router_ports(addrs.get("gateway"))
    if args.deep:
        check_deep(addrs.get("network"), addrs.get("gateway"))
    else:
        section("Deep")
        print("(omitido — pasa --deep en casa si quieres inventario de la subnet)")
        add(INFO, "Modo deep no activado", "python3 ~/wifi_selfcheck.py --deep")
    return summarize()


if __name__ == "__main__":
    sys.exit(main())
