#!/usr/bin/env python3
"""
net_selfcheck.py — autoanálisis DEFENSIVO local (solo lectura).

Alcance: inventaría y endurecimiento de ESTA máquina. Pensado para ejecución
rutinaria (diaria/semanal): rápido, poco ruido, mensajes en español.

NO hace: escaneo remoto de hosts ajenos, exploits, payloads, fuerza bruta,
cracking ni bypass de autenticación. Ejecutar solo en sistemas propios.
"""

from __future__ import annotations

import grp
import os
import pwd
import re
import shutil
import socket
import stat
import subprocess
import sys
from pathlib import Path

HOME = Path.home()
OK, WARN, INFO, FAIL = "OK", "WARN", "INFO", "FAIL"
findings: list[tuple[str, str, str]] = []

# Puertos conocidos: INFO si expuestos (uso habitual), WARN si sensibles.
KNOWN_OK = {
    22: "ssh",
    53: "dns",
    22000: "syncthing",
    21027: "syncthing-discovery",
}
SENSITIVE = {
    21: "ftp",
    23: "telnet",
    111: "rpcbind",
    445: "smb",
    3389: "rdp",
    5900: "vnc",
    6379: "redis",
    27017: "mongodb",
    3306: "mysql",
    5432: "postgresql",
}


def add(level: str, title: str, detail: str = "") -> None:
    findings.append((level, title, detail))


def run(cmd: list[str], timeout: float = 10.0) -> tuple[int, str, str]:
    try:
        p = subprocess.run(
            cmd, capture_output=True, text=True, timeout=timeout, check=False
        )
        return p.returncode, p.stdout.strip(), p.stderr.strip()
    except FileNotFoundError:
        return 127, "", f"no encontrado: {cmd[0]}"
    except subprocess.TimeoutExpired:
        return 124, "", "timeout"


def section(title: str) -> None:
    print(f"\n== {title} ==")


def _is_local_only(line: str) -> bool:
    return "127.0.0.1:" in line or "[::1]:" in line or " ::1:" in line


def _is_all_interfaces(line: str) -> bool:
    # Escuchar en todas las interfaces (IPv4/IPv6)
    return bool(
        re.search(r"\s0\.0\.0\.0:\d+", line)
        or re.search(r"\s\*:\d+", line)
        or re.search(r"\s\[::\]:\d+", line)
        or re.search(r"\s:::?\d+", line)
    )


def _extract_port(line: str) -> int | None:
    # Último :PUERTO antes de peer/proceso en salida ss
    m = re.search(r":(\d+)\s", line)
    if m:
        return int(m.group(1))
    m = re.search(r":(\d+)$", line.rstrip())
    return int(m.group(1)) if m else None


def check_identity() -> None:
    section("Identidad")
    user = pwd.getpwuid(os.getuid())
    gids = os.getgroups()
    groups = []
    for g in gids:
        try:
            groups.append(grp.getgrgid(g).gr_name)
        except KeyError:
            groups.append(str(g))
    host = socket.gethostname()
    uname = os.uname()
    print(f"usuario: {user.pw_name}  uid={user.pw_uid}  home={user.pw_dir}")
    print(f"grupos: {', '.join(groups)}")
    print(f"host: {host}")
    print(f"kernel: {uname.sysname} {uname.release} ({uname.machine})")
    code, out, _ = run(["uptime", "-p"])
    if code != 0:
        code, out, _ = run(["uptime"])
    if out:
        print(f"uptime: {out}")
    add(INFO, "Ejecutando como usuario local", f"{user.pw_name}@{host}")


def check_listeners() -> dict[int, str]:
    """Devuelve mapa puerto->línea ss de listeners expuestos (para procesos)."""
    section("Sockets en escucha (vista local)")
    code, out, err = run(["ss", "-tulpn"])
    if code != 0:
        code, out, err = run(["ss", "-tuln"])
    if code != 0 or not out:
        add(WARN, "No se pudieron listar listeners", err or "ss no disponible")
        print("(ss falló; instala iproute2)")
        return {}

    lines = [ln for ln in out.splitlines() if ln and not ln.startswith("Netid")]
    local_n = exposed_n = 0
    exposed_map: dict[int, str] = {}
    # Un finding por puerto (IPv4+IPv6 no duplican ruido)
    seen_ports: set[int] = set()
    other_ports: list[int] = []

    for ln in lines:
        port = _extract_port(ln)
        local = _is_local_only(ln)
        all_if = _is_all_interfaces(ln)
        if local:
            local_n += 1
        if all_if and not local:
            exposed_n += 1
            if port is not None:
                exposed_map.setdefault(port, ln.strip())
                if port in seen_ports:
                    continue
                seen_ports.add(port)
                if port in SENSITIVE:
                    add(
                        WARN,
                        f"Servicio sensible expuesto :{port} ({SENSITIVE[port]})",
                        ln.strip()[:120],
                    )
                elif port in KNOWN_OK:
                    add(
                        INFO,
                        f"Servicio conocido :{port} ({KNOWN_OK[port]}) en todas las interfaces",
                        "esperado si lo usas en red local",
                    )
                else:
                    other_ports.append(port)

    print(
        f"listeners: {len(lines)} total, {local_n} solo-localhost, {exposed_n} en todas las interfaces"
    )
    shown = 0
    for ln in lines:
        if not (_is_all_interfaces(ln) and not _is_local_only(ln)):
            continue
        print(f"  {ln.strip()}")
        shown += 1
        if shown >= 12:
            rest = exposed_n - shown
            if rest > 0:
                print(f"  … (+{rest}; detalle: ss -tulpn)")
            break
    if shown == 0 and lines:
        print("  (ninguno expuesto fuera de localhost — bien)")

    if other_ports:
        other_ports.sort()
        add(
            INFO,
            f"Otros puertos expuestos: {', '.join(':'+str(p) for p in other_ports[:12])}",
            "dhcp/mdns/efímeros suelen ser normales",
        )
    if exposed_n == 0:
        add(OK, "Ningún listener obvio en todas las interfaces", "")
    else:
        add(
            INFO,
            f"{exposed_n} socket(s) / {len(seen_ports)} puerto(s) en todas las interfaces",
            "Preferir 127.0.0.1 si el servicio es solo local",
        )
    return exposed_map


def check_ssh() -> None:
    section("SSH (claves y sshd_config si legible)")
    ssh = HOME / ".ssh"
    if not ssh.exists():
        add(INFO, "~/.ssh no existe", "OK si aún no usas claves SSH")
        print("(sin ~/.ssh)")
    else:
        mode = ssh.stat().st_mode & 0o777
        print(f"{ssh}: modo {oct(mode)}")
        if mode & 0o077:
            add(FAIL, "~/.ssh es accesible por grupo/otros", oct(mode))
        else:
            add(OK, "Permisos de ~/.ssh adecuados", oct(mode))

        for name in ("id_rsa", "id_ed25519", "id_ecdsa", "id_dsa"):
            path = ssh / name
            if not path.exists():
                continue
            m = path.stat().st_mode & 0o777
            print(f"  clave privada {name}: {oct(m)}")
            if m & 0o077:
                add(FAIL, f"Clave privada demasiado abierta: {name}", oct(m))
            else:
                add(OK, f"Permisos OK de clave privada: {name}", oct(m))

        ak = ssh / "authorized_keys"
        if ak.exists():
            try:
                nkeys = sum(
                    1
                    for ln in ak.read_text(errors="replace").splitlines()
                    if ln.strip() and not ln.strip().startswith("#")
                )
            except OSError as e:
                nkeys = -1
                add(WARN, "No se pudo leer authorized_keys", str(e))
            if nkeys >= 0:
                print(f"  authorized_keys: {nkeys} clave(s)")
                add(INFO, f"authorized_keys con {nkeys} entrada(s)", str(ak))
                am = ak.stat().st_mode & 0o777
                if am & 0o022:
                    add(WARN, "authorized_keys escribible por grupo/otros", oct(am))

    cfg = Path("/etc/ssh/sshd_config")
    if cfg.is_file() and os.access(cfg, os.R_OK):
        try:
            text = cfg.read_text(errors="replace")
        except OSError as e:
            add(INFO, "sshd_config no legible", str(e))
            return

        # Última directiva efectiva (sin Include profundo — KISS)
        def last_val(key: str) -> str | None:
            val = None
            for ln in text.splitlines():
                s = ln.strip()
                if not s or s.startswith("#"):
                    continue
                parts = s.split(None, 1)
                if len(parts) == 2 and parts[0].lower() == key.lower():
                    val = parts[1].strip()
            return val

        for key in (
            "PasswordAuthentication",
            "PermitRootLogin",
            "PubkeyAuthentication",
        ):
            v = last_val(key)
            if v is None:
                print(f"  {key}: (no definido / default del paquete)")
                add(INFO, f"sshd {key} no explícito", "revisa defaults del paquete")
                continue
            print(f"  {key}: {v}")
            low = v.lower()
            if key == "PasswordAuthentication" and low in ("yes", "true"):
                add(WARN, "PasswordAuthentication=yes", "mejor solo claves públicas")
            elif key == "PermitRootLogin" and low in ("yes", "true"):
                add(WARN, "PermitRootLogin=yes", "restringe root por SSH")
            elif key == "PermitRootLogin" and low in (
                "no",
                "prohibit-password",
                "without-password",
            ):
                add(OK, f"PermitRootLogin={v}", "")
            elif key == "PubkeyAuthentication" and low in ("yes", "true"):
                add(OK, "PubkeyAuthentication habilitado", v)
            elif key == "PasswordAuthentication" and low in ("no", "false"):
                add(OK, "PasswordAuthentication deshabilitado", v)
            else:
                add(INFO, f"sshd {key}={v}", "")
    else:
        add(INFO, "/etc/ssh/sshd_config no legible (sin root)", "omitido")
        print("(sshd_config no legible)")


def check_firewall() -> None:
    section("Cortafuegos (solo lectura)")
    if shutil.which("ufw"):
        _, out, err = run(["ufw", "status"])
        text = out or err
        print((text or "(vacío)")[:400])
        if "inactive" in text.lower():
            add(WARN, "ufw inactivo", "actívalo si quieres filtrar tráfico")
        elif "active" in text.lower():
            add(OK, "ufw activo", "")
        else:
            add(INFO, "ufw presente", text[:120])
        return
    if shutil.which("firewall-cmd"):
        _, out, err = run(["firewall-cmd", "--state"])
        print(out or err)
        if (out or "").strip() == "running":
            add(OK, "firewalld en ejecución", "")
        else:
            add(WARN, "firewalld no en ejecución", out or err)
        return
    for tool, args in (("nft", ["list", "ruleset"]), ("iptables", ["-L", "-n"])):
        if not shutil.which(tool):
            continue
        code, out, err = run([tool, *args])
        if code != 0:
            add(
                INFO,
                f"{tool} instalado pero listar requiere privilegios",
                (err or "")[:120],
            )
            print(f"{tool}: sin privilegios para listar (INFO)")
        else:
            nlines = len([ln for ln in (out or "").splitlines() if ln.strip()])
            add(
                INFO, f"{tool}: reglas legibles ({nlines} líneas)", "revisa manualmente"
            )
            print(f"{tool}: {nlines} líneas de reglas (no se vuelcan)")
        return
    add(INFO, "Sin ufw/firewalld en PATH", "puede haber nftables vía root")
    print("(sin CLI de cortafuegos común)")


def check_home() -> None:
    section("Home (permisos superficiales)")
    # find $HOME -maxdepth 2 -perm -0002 (opcional / shallow)
    bad: list[str] = []
    hist = HOME / ".bash_history"
    if hist.exists():
        hm = hist.stat().st_mode & 0o777
        print(f".bash_history: {oct(hm)}")
        if hm & 0o077:
            add(WARN, ".bash_history legible por grupo/otros", oct(hm))
        else:
            add(OK, "Permisos de .bash_history OK", oct(hm))
    else:
        print(".bash_history: no existe")

    # shallow world-writable: home + depth 2 via walk limited
    try:
        for root, dirs, files in os.walk(HOME, topdown=True, followlinks=False):
            depth = Path(root).relative_to(HOME).parts
            if len(depth) > 2:
                dirs.clear()
                continue
            # no entrar en dirs profundas
            if len(depth) >= 2:
                dirs.clear()
            for name in dirs + files:
                p = Path(root) / name
                try:
                    st = p.lstat()
                except OSError:
                    continue
                if stat.S_ISLNK(st.st_mode):
                    continue
                if st.st_mode & stat.S_IWOTH:
                    bad.append(f"{p} {oct(st.st_mode & 0o777)}")
    except PermissionError:
        add(WARN, "No se pudo recorrer $HOME", "")
        return

    if bad:
        for b in bad[:10]:
            print(f"  world-writable: {b}")
        if len(bad) > 10:
            print(f"  … y {len(bad) - 10} más")
        add(
            WARN,
            f"{len(bad)} ruta(s) world-writable bajo $HOME (maxdepth 2)",
            "; ".join(bad[:3]),
        )
    else:
        print("(ninguna world-writable en maxdepth 2)")
        add(OK, "Sin world-writable en $HOME (shallow)", "")

    # SUID en PATH del usuario — NO buscar en todo el sistema
    path_dirs = [Path(p) for p in os.environ.get("PATH", "").split(":") if p]
    suid_hits: list[str] = []
    for d in path_dirs:
        if not d.is_dir():
            continue
        # Solo directorios bajo home o típicos de usuario — evitar /usr/bin agresivo
        # Pedido: "archivos con bit SUID en PATH del usuario NO" → no escanear SUID agresivo
        # Interpretación: NO buscar SUID en PATH del sistema; omitir o solo home bins
        try:
            home_resolved = HOME.resolve()
            if not str(d.resolve()).startswith(str(home_resolved)):
                continue
        except OSError:
            continue
        try:
            for f in d.iterdir():
                try:
                    st = f.lstat()
                except OSError:
                    continue
                if st.st_mode & (stat.S_ISUID | stat.S_ISGID):
                    suid_hits.append(str(f))
        except OSError:
            continue
    if suid_hits:
        add(
            WARN,
            f"SUID/SGID en binarios bajo $HOME en PATH: {len(suid_hits)}",
            ", ".join(suid_hits[:5]),
        )
        for h in suid_hits[:5]:
            print(f"  SUID/SGID: {h}")
    else:
        print("(sin SUID/SGID en bins de $HOME en PATH)")
        add(OK, "Sin SUID/SGID en PATH bajo $HOME", "")


def check_curious_processes(exposed: dict[int, str]) -> None:
    section("Procesos asociados a listeners expuestos")
    if not exposed:
        print("(nada expuesto — omitido)")
        add(INFO, "Sin procesos curiosos (no hay listeners expuestos)", "")
        return
    # Extraer pid de líneas ss tipo users:(("sshd",pid=123,fd=3))
    pids: set[int] = set()
    for ln in exposed.values():
        for m in re.finditer(r"pid=(\d+)", ln):
            pids.add(int(m.group(1)))
        # a veces (("cmd",pid=N
        for m in re.finditer(r'\("([^"]+)",pid=(\d+)', ln):
            pids.add(int(m.group(2)))
    if not pids:
        print("(ss no mostró PIDs — hace falta privilegios o iproute2 completo)")
        add(
            INFO,
            "Listeners expuestos sin PID visible",
            "ss -tulpn como root da más detalle",
        )
        return
    for pid in sorted(pids)[:20]:
        cmdline = Path(f"/proc/{pid}/cmdline")
        try:
            raw = (
                cmdline.read_bytes()
                .replace(b"\x00", b" ")
                .decode(errors="replace")
                .strip()
            )
            print(f"  pid {pid}: {raw[:120] or '(vacío)'}")
        except OSError:
            print(f"  pid {pid}: (proceso ya no existe)")
    add(
        INFO,
        f"{len(pids)} proceso(s) con listener expuesto",
        "solo inventario; no se mata nada",
    )


def check_updates() -> None:
    section("Actualizaciones (xbps)")
    if shutil.which("xbps-install"):
        code, out, err = run(["xbps-install", "-un"], timeout=30.0)
        if code == 0 and out:
            n = len([ln for ln in out.splitlines() if ln.strip()])
            print(f"{n} paquete(s) con actualización disponible")
            # Mostrar solo unos pocos nombres
            names = []
            for ln in out.splitlines()[:8]:
                names.append(ln.split()[0] if ln.split() else ln)
            if names:
                print("  ejemplos: " + ", ".join(names))
            add(INFO, f"{n} actualizaciones xbps pendientes", "sudo xbps-install -Su")
        elif code == 0:
            print("sin actualizaciones pendientes")
            add(OK, "xbps sin upgrades pendientes", "")
        else:
            add(
                INFO, "No se pudo listar upgrades xbps con claridad", (err or out)[:160]
            )
            print(err or out or "xbps-install -un inconcluso")
        return
    add(INFO, "xbps-install no está en PATH", "¿no es Void?")
    print("(sin xbps-install)")


def check_dns() -> None:
    section("DNS (/etc/resolv.conf)")
    path = Path("/etc/resolv.conf")
    if not path.is_file():
        add(INFO, "Sin /etc/resolv.conf", "")
        print("(ausente)")
        return
    try:
        lines = path.read_text(errors="replace").splitlines()
    except OSError as e:
        add(WARN, "No se pudo leer resolv.conf", str(e))
        return
    nameservers = []
    search = []
    for ln in lines:
        s = ln.strip()
        if s.startswith("#") or not s:
            continue
        parts = s.split()
        if parts[0] == "nameserver" and len(parts) > 1:
            nameservers.append(parts[1])
        elif parts[0] in ("search", "domain") and len(parts) > 1:
            search.extend(parts[1:])
    print(f"nameservers: {', '.join(nameservers) or '(ninguno)'}")
    if search:
        print(f"search/domain: {' '.join(search)}")
    add(INFO, f"DNS: {len(nameservers)} nameserver(s)", ", ".join(nameservers[:4]))


def check_sysctl() -> None:
    section("Sysctl legibles (red)")
    base = Path("/proc/sys")
    if not base.exists():
        add(INFO, "/proc/sys no disponible", "")
        print("(omitido)")
        return
    knobs = {
        "net/ipv4/ip_forward": "ip_forward",
        "net/ipv4/conf/all/rp_filter": "rp_filter(all)",
        "net/ipv4/conf/default/rp_filter": "rp_filter(default)",
    }
    for rel, label in knobs.items():
        p = base / rel
        try:
            val = p.read_text().strip()
        except OSError:
            print(f"  {label}: (no legible)")
            continue
        print(f"  {label}: {val}")
        if rel.endswith("ip_forward"):
            if val == "1":
                add(
                    INFO,
                    "ip_forward=1 (máquina actúa como router)",
                    "esperado en gateways",
                )
            else:
                add(OK, "ip_forward desactivado", val)
        elif "rp_filter" in rel:
            if val == "0":
                add(WARN, f"{label}=0", "rp_filter desactivado reduce anti-spoofing")
            else:
                add(OK, f"{label}={val}", "")


def check_uid0() -> None:
    section("Usuarios uid 0 (/etc/passwd)")
    path = Path("/etc/passwd")
    if not path.is_file() or not os.access(path, os.R_OK):
        add(INFO, "/etc/passwd no legible", "")
        print("(omitido)")
        return
    roots = []
    try:
        for ln in path.read_text(errors="replace").splitlines():
            parts = ln.split(":")
            if len(parts) >= 3 and parts[2] == "0":
                roots.append(parts[0])
    except OSError as e:
        add(WARN, "Error leyendo /etc/passwd", str(e))
        return
    print(f"cuentas uid 0: {', '.join(roots)} ({len(roots)})")
    if len(roots) == 1 and roots[0] == "root":
        add(OK, "Solo root tiene uid 0", "")
    elif len(roots) > 1:
        add(WARN, f"{len(roots)} cuentas con uid 0", ", ".join(roots))
    else:
        add(INFO, f"uid 0: {roots}", "")


def check_cron() -> None:
    section("Cron del usuario")
    code, out, err = run(["crontab", "-l"])
    if code != 0:
        msg = (err or out or "").lower()
        if "no crontab" in msg or code == 1:
            print("(sin crontab de usuario)")
            add(OK, "Sin crontab de usuario", "")
        else:
            add(INFO, "crontab -l no disponible", (err or out)[:120])
            print(err or out or "(error)")
        return
    lines = [
        ln for ln in out.splitlines() if ln.strip() and not ln.strip().startswith("#")
    ]
    print(f"{len(lines)} entrada(s) activa(s)")
    for ln in lines[:8]:
        print(f"  {ln}")
    if len(lines) > 8:
        print(f"  … y {len(lines) - 8} más")
    add(INFO, f"crontab de usuario: {len(lines)} job(s)", "")


def check_containers() -> None:
    section("Sockets Docker/Podman")
    candidates = [
        Path("/var/run/docker.sock"),
        Path("/run/docker.sock"),
        Path("/var/run/podman/podman.sock"),
        Path("/run/podman/podman.sock"),
    ]
    found = False
    for p in candidates:
        if not p.exists():
            continue
        found = True
        try:
            st = p.lstat()
            mode = oct(st.st_mode & 0o777)
            print(f"  {p}: modo {mode} uid={st.st_uid} gid={st.st_gid}")
            if st.st_mode & stat.S_IROTH or st.st_mode & stat.S_IWOTH:
                add(WARN, f"Socket contenedor world-accessible: {p}", mode)
            else:
                add(INFO, f"Socket presente: {p}", f"modo {mode}")
        except OSError as e:
            add(INFO, f"Socket {p} existe pero no se pudo stat", str(e))
    if not found:
        print("(no hay docker.sock / podman.sock)")
        add(OK, "Sin socket Docker/Podman en /var/run|/run", "")


def _color(level: str) -> str:
    """ANSI colors only on a TTY; levels stay readable in logs/cron."""
    if not sys.stdout.isatty():
        return ""
    return {
        OK: "\033[1;32m",  # green
        WARN: "\033[1;33m",  # yellow
        FAIL: "\033[1;31m",  # red
        INFO: "\033[1;36m",  # cyan
    }.get(level, "")


def _reset() -> str:
    return "\033[0m" if sys.stdout.isatty() else ""


def summarize() -> int:
    section("Resumen")
    counts = {OK: 0, WARN: 0, FAIL: 0, INFO: 0}
    # Cabecera con tabs: NIVEL | título | detalle
    print(f"{'NIVEL':<6}\t{'hallazgo'}\t{'detalle'}")
    print(f"{'------':<6}\t{'--------'}\t{'-------'}")
    for level, title, detail in findings:
        counts[level] = counts.get(level, 0) + 1
        c, r = _color(level), _reset()
        # tabs entre columnas; nivel coloreado y ancho fijo
        print(f"{c}{level:<6}{r}\t{title}\t{detail}")
    # Totales coloreados
    parts = []
    for lvl in (OK, WARN, FAIL, INFO):
        parts.append(f"{_color(lvl)}{lvl}={counts[lvl]}{_reset()}")
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
    print("net_selfcheck — auditoría defensiva local (solo lectura)")
    print("Alcance: esta máquina. Sin escaneo remoto ni exploits.")
    check_identity()
    exposed = check_listeners()
    check_ssh()
    check_firewall()
    check_home()
    check_curious_processes(exposed)
    check_updates()
    check_dns()
    check_sysctl()
    check_uid0()
    check_cron()
    check_containers()
    return summarize()


if __name__ == "__main__":
    sys.exit(main())
