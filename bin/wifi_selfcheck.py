#!/usr/bin/env python3
"""Passive WiFi audit: no rescan, ping sweep, router probing or password reads."""
from __future__ import annotations

import argparse
import json
import re
from security_core import Audit, nm_fields, standalone


def connected(state):
    return state == "connected" or state.startswith("connected (")


def encryption_findings(a, iface, negotiated, advertised, profile):
    cipher = negotiated.get("pairwise_cipher", "").upper()
    method = negotiated.get("key_mgmt", "").upper()
    security = advertised.upper()
    km = profile.get("802-11-wireless-security.key-mgmt", "").lower()
    proto = profile.get("802-11-wireless-security.proto", "").lower()
    if cipher in ("NONE", "WEP-40", "WEP-104") or method == "NONE" and negotiated.get("wpa_state") == "COMPLETED":
        a.add("FAIL", f"wifi-open:{iface}", "WiFi sin cifrado robusto", f"Negociado: {method}/{cipher}", "Desconecta de esa red o usa un transporte cifrado de extremo a extremo; configura WPA2-AES o WPA3 si administras el AP.")
    elif security in ("", "--", "WEP") and advertised and not km.startswith(("owe", "sae", "wpa")):
        a.add("FAIL", f"wifi-open:{iface}", "Punto de acceso activo anuncia red abierta o WEP", f"Seguridad anunciada: {advertised}", "Evita esa red para tráfico sensible; revisa la configuración del router.")
    if cipher == "TKIP" or "WPA-PSK" == method or proto == "wpa" or security == "WPA1":
        a.add("WARN", f"wifi-legacy:{iface}", "WiFi usa o permite cifrado heredado", f"Negociado={method}/{cipher}; anunciado={advertised}; perfil proto={proto}", "Usa WPA2 con CCMP/AES o WPA3; no mezcles WPA1/TKIP si no es necesario.")
    if not negotiated:
        a.skip(f"Cifrado WiFi negociado ({iface})", "wpa_cli no proporcionó el estado; se evaluaron solo el AP cacheado y el perfil, no se afirma que wpa-psk sea WPA2.")
    if not negotiated and not advertised:
        a.skip(f"Seguridad del AP ({iface})", "NetworkManager no tiene evidencia del AP activo en caché; no se inicia un escaneo.")


def audit(policy=None, facts=None, budget=7):
    a = Audit("wifi", budget)

    def check_wifi():
        rc, out, err = a.run(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "device", "status"])
        if rc:
            a.skip("WiFi", "NetworkManager no disponible; no se interpreta como WiFi insegura. " + err)
            return
        rows = [nm_fields(line) for line in out.splitlines()]
        interfaces = [r[0] for r in rows if len(r) >= 3 and r[1] == "wifi" and connected(r[2])]
        if not interfaces:
            a.inventory["wifi"] = "sin WiFi conectada (no es un fallo de seguridad)"
            return
        rc, out, _ = a.run(["nmcli", "-t", "-f", "ACTIVE,DEVICE,BSSID,SSID,SECURITY", "device", "wifi", "list", "--rescan", "no"])
        aps = [nm_fields(line) for line in out.splitlines()] if rc == 0 else []
        radios = []
        for iface in interfaces:
            rc, out, _ = a.run(["nmcli", "-g", "GENERAL.CON-UUID", "device", "show", iface])
            uuid = out if rc == 0 and out != "--" else ""
            profile = {}
            if uuid:
                rc, out, _ = a.run(["nmcli", "-t", "-f", "802-11-wireless-security.key-mgmt,802-11-wireless-security.proto,802-11-wireless-security.pairwise,802-11-wireless-security.pmf", "connection", "show", "uuid", uuid])
                if rc == 0:
                    profile = {r[0]: r[1] for line in out.splitlines() for r in [nm_fields(line)] if len(r) >= 2}
            active = next((r for r in aps if len(r) >= 5 and r[0] == "yes" and r[1] == iface), None)
            negotiated = {}
            rc, out, _ = a.run(["wpa_cli", "-i", iface, "status"], timeout=1)
            if rc == 0:
                negotiated = dict(line.split("=", 1) for line in out.splitlines() if "=" in line)
                if negotiated.get("wpa_state") != "COMPLETED":
                    negotiated = {}
            # Never request or persist PSKs, EAP passwords, or full profile dumps.
            negotiated = {k: v for k, v in negotiated.items() if k in ("pairwise_cipher", "group_cipher", "key_mgmt", "wpa_state")}
            security = active[4] if active else ""
            encryption_findings(a, iface, negotiated, security, profile)
            radio = dict(interface=iface, connection_uuid=uuid, bssid=active[2] if active else None,
                         ssid=active[3] if active else None, advertised_security=security,
                         negotiated=negotiated, profile=profile)
            rc, out, _ = a.run(["ip", "-j", "-4", "route", "show", "default", "dev", iface])
            routes = json.loads(out or "[]") if rc == 0 else []
            gateway = next((r["gateway"] for r in sorted(routes, key=lambda r: r.get("metric", 0)) if "gateway" in r), None)
            if gateway:
                rc, out, _ = a.run(["ip", "-j", "neigh", "show", "to", gateway, "dev", iface])
                neighbours = json.loads(out or "[]") if rc == 0 else []
                radio["gateway"] = gateway
                radio["gateway_mac"] = next((n["lladdr"] for n in neighbours if n.get("lladdr")), None)
            radios.append(radio)
        a.inventory["wifi"] = radios

    a.check("WiFi pasiva", check_wifi)
    return a.result()


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--json", action="store_true")
    p.add_argument("--verbose", action="store_true")
    p.add_argument("--no-color", action="store_true")
    p.add_argument("--skip-router-ports", action="store_true", help="compatibilidad: nunca se prueban puertos del router")
    p.add_argument("--deep", action="store_true", help="obsoleto: esta auditoría no hace escaneo activo")
    args = p.parse_args()
    result = audit()
    if args.deep:
        result["skipped"].append(dict(check="Inventario activo", reason="--deep retirado: sin barridos ni pruebas al router; usa una herramienta separada de inventario autorizado."))
    raise SystemExit(standalone(result, args.json, args.verbose))
