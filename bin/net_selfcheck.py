#!/usr/bin/env python3
"""Bounded local audit. Read-only; no network scan, sudo prompt or remediation."""
from __future__ import annotations

import argparse
import ipaddress
import json
import os
from pathlib import Path
import pwd
import shutil
import stat
import time

from security_core import Audit, is_loopback, load_policy, parse_listeners, standalone


SENSITIVE = {21: "FTP", 23: "Telnet", 111: "RPC", 445: "SMB", 2375: "Docker sin TLS",
             3306: "MySQL", 5432: "PostgreSQL", 5900: "VNC", 6379: "Redis",
             6566: "SANE (escáner)", 11434: "API Ollama", 27017: "MongoDB"}


def effective_rp_filter(all_value, interface_value):
    return max(int(all_value), int(interface_value))


def protected_by_ancestor(path, uid):
    """A private owner-only ancestor makes a 0666 cache lock unreachable to peers."""
    for parent in Path(path).parents:
        info = parent.stat()
        if info.st_uid == uid and not info.st_mode & 0o011:
            return True
    return False


def audit(policy=None, facts=None, budget=10):
    a = Audit("local", budget)
    home = Path.home()
    policy = load_policy() if policy is None else policy
    facts = facts or {}

    def listeners():
        rc, out, err = a.run(["ss", "-H", "-lntup"])
        if rc:
            a.skip("listeners", err); return
        records = parse_listeners(out)
        a.inventory["listeners"] = records
        exposed = [r for r in records if not is_loopback(r["address"])]
        expected = policy.get("allowed_listeners", [])
        other = {}
        for proto, port in sorted({(r["protocol"], r["port"]) for r in exposed}):
            items = [r for r in exposed if r["protocol"] == proto and r["port"] == port]
            if all(any(p.get("protocol") == proto and p.get("port") == port and
                       (not p.get("address") or p["address"] == r["address"])
                       for p in expected) for r in items):
                continue
            # UDP client sockets are not equivalent to an unprotected server.
            if proto == "udp" and port >= 32768 and port not in SENSITIVE:
                continue
            evidence = ", ".join(f"{r['address']}:{port} ({r['process'] or 'proceso no visible'})" for r in items)
            if port not in SENSITIVE:
                for r in items:
                    other.setdefault(r["process"] or "proceso no visible", set()).add(f"{proto} {r['address']}:{port}")
                continue
            name = SENSITIVE.get(port, "servicio no declarado")
            a.add("FAIL" if port in (23, 2375) else "WARN", f"listener:{proto}:{port}",
                  f"{name}: escucha {proto} fuera de loopback", evidence,
                  "Si no necesitas acceso remoto, enlaza a 127.0.0.1; si lo necesitas, limita orígenes y revisa autenticación. Escucha no demuestra acceso desde Internet.")
        for process, ports in sorted(other.items()):
            a.add("WARN", f"listener-process:{process}", f"Acceso de red no declarado: {process}",
                  ", ".join(sorted(ports)), "Confirma si necesitas su función de servidor/descubrimiento. Si es esperada, declárala por puerto en la política; no se considera segura solo por reconocer el nombre del proceso.")

    def permissions():
        paths = [home, home / ".ssh", home / ".ssh/config", home / ".ssh/authorized_keys",
                 home / ".histfile", home / ".zsh_history", home / ".bash_history"]
        ssh = home / ".ssh"
        if ssh.is_dir():
            for p in list(ssh.iterdir())[:100]:
                if p.is_file() and not p.name.endswith((".pub", ".old")) and p.stat().st_size < 100000:
                    with p.open("rb") as stream:
                        header = stream.read(80)
                    if b"PRIVATE KEY-----" in header:
                        st = p.stat()
                        if st.st_mode & 0o077:
                            a.add("FAIL", f"key:{p.name}", "Clave privada con permisos demasiado abiertos",
                                  f"{p}: {stat.S_IMODE(st.st_mode):04o}", f"chmod 600 '{p}'")
        for p in paths:
            if not p.exists():
                continue
            st = p.stat()
            if st.st_mode & 0o022 and not protected_by_ancestor(p, os.getuid()):
                a.add("FAIL", f"writable:{p.name}", "Ruta sensible modificable por grupo/otros",
                      f"{p}: {stat.S_IMODE(st.st_mode):04o}", "Revisa propietarios y elimina permisos de escritura ajenos.")
            elif p.name in (".histfile", ".zsh_history", ".bash_history") and st.st_mode & 0o044 and not protected_by_ancestor(p, os.getuid()):
                a.add("WARN", f"history:{p.name}", "Historial accesible a otros usuarios locales",
                      str(p), f"chmod 600 '{p}'")
        for value in dict.fromkeys(os.environ.get("PATH", "").split(":")):
            p = Path(value or ".")
            if not value or not p.is_absolute():
                a.add("WARN", "relative-path", "PATH incluye el directorio actual o una ruta relativa",
                      value or "entrada vacía", "Usa solo directorios absolutos de confianza en PATH.")
                continue
            if p.is_dir() and p.stat().st_mode & 0o002 and not protected_by_ancestor(p, os.getuid()):
                a.add("FAIL", f"path:{p}", "Directorio de PATH modificable por cualquier usuario",
                      str(p), "Quita escritura a otros; no ejecutes binarios de ese directorio hasta revisarlo.")

    def ssh_config():
        if facts.get("sshd_stale_pids"):
            a.add("WARN", "ssh-outdated-daemon", "sshd ejecuta un binario anterior al instalado",
                  "PID: " + ", ".join(map(str, facts["sshd_stale_pids"])),
                  "Tras validar sshd -t y conservar acceso local, reinicia SSH con el gestor de servicios de tu distribución; puede evitar fallos después de actualizar OpenSSH.")
        if not any(r["port"] == 22 and r["protocol"] == "tcp" for r in a.inventory.get("listeners", [])):
            return
        effective = facts.get("sshd", {})
        if not effective:
            executable = shutil.which("sshd") or "/usr/sbin/sshd"
            rc, out, err = a.run([executable, "-T", "-C", f"user={pwd.getpwuid(os.getuid()).pw_name},host=localhost,addr=192.0.2.1"])
            if rc:
                a.skip("SSH efectivo", "sshd -T requiere privilegios/host keys; no se deducen valores de líneas comentadas o de Includes.")
                return
            effective = dict(line.split(None, 1) for line in out.splitlines() if " " in line)
        a.inventory["ssh_effective"] = effective
        if effective.get("permitrootlogin") == "yes":
            a.add("WARN", "ssh-root", "SSH permite autenticar directamente como root", "PermitRootLogin=yes", "Usa una cuenta personal con sudo y deshabilita el acceso directo de root.")
        if effective.get("permitemptypasswords") == "yes":
            a.add("FAIL", "ssh-empty", "SSH admite contraseñas vacías", "PermitEmptyPasswords=yes", "Deshabilita esta opción y verifica las cuentas sin contraseña.")
        if effective.get("passwordauthentication") == "yes" or effective.get("kbdinteractiveauthentication") == "yes":
            a.add("WARN", "ssh-password", "SSH permite autenticación interactiva/contraseña",
                  "Puede ser intencional (p. ej. MFA); no es evidencia de intrusión.",
                  "Confirma acceso por claves y requisitos de MFA antes de restringirlo. No cambies esta opción a ciegas.")

    def firewall():
        nft = facts.get("nft")
        if nft is None:
            rc, out, err = a.run([shutil.which("nft") or "/usr/sbin/nft", "-j", "list", "ruleset"])
            nft = json.loads(out) if rc == 0 else None
        if nft is not None:
            chains = [v["chain"] for v in nft.get("nftables", []) if "chain" in v and v["chain"].get("hook") == "input"]
            a.inventory["input_chains"] = [{k: c.get(k) for k in ("family", "table", "name", "policy")} for c in chains]
            covered = {family: any(c.get("family") in (family, "inet") and c.get("policy") == "drop" for c in chains) for family in ("ip", "ip6")}
            legacy = [facts.get(tool, "") for tool in ("iptables-save", "ip6tables-save")]
            for family, table in zip(("ip", "ip6"), legacy):
                if ":INPUT DROP " in table or ":INPUT REJECT " in table:
                    covered[family] = True
            if not all(covered.values()):
                a.add("WARN", "firewall-policy", "No se verifica política INPUT de denegación por defecto para IPv4 e IPv6",
                      f"Políticas nft observadas: {a.inventory['input_chains'] or 'ninguna cadena input'}",
                      "Revisa reglas y excepciones sin bloquear tu SSH. Las cadenas Docker FORWARD no sustituyen INPUT del host.")
            else:
                a.inventory["firewall_note"] = "Política drop observada en IPv4/IPv6; no se valida la seguridad de cada excepción ni el tráfico reenviado por contenedores."
            return
        tables = []
        for tool in ("iptables-save", "ip6tables-save"):
            out = facts.get(tool)
            if out is None:
                rc, value, _ = a.run([shutil.which(tool) or "/usr/sbin/" + tool])
                out = value if rc == 0 else None
            tables.append(out)
        if any(out is None or ":INPUT " not in out for out in tables):
            a.skip("Cortafuegos", "Sin evidencia completa de INPUT IPv4/IPv6 con estos permisos (una salida vacía de iptables-save no prueba una política). No se considera protegido por tener nft/iptables instalado.")
        elif not all(":INPUT DROP " in out or ":INPUT REJECT " in out for out in tables):
            a.add("WARN", "firewall-policy", "INPUT no deniega por defecto en ambas familias", "Políticas iptables/ip6tables leídas", "Revisa la política y sus excepciones; no actives bloqueo remoto sin una regla SSH probada.")

    def sysctls():
        rc, out, _ = a.run(["ip", "-j", "-4", "route", "show", "default"])
        interfaces = sorted({r["dev"] for r in json.loads(out or "[]") if r.get("dev")}) if rc == 0 else []
        def read(key):
            return Path("/proc/sys/" + key.replace(".", "/")).read_text().strip()
        modes = {}
        for iface in interfaces:
            modes[iface] = effective_rp_filter(read("net.ipv4.conf.all.rp_filter"), read(f"net.ipv4.conf.{iface}.rp_filter"))
        a.inventory["rp_filter_effective"] = modes
        disabled = [i for i, v in modes.items() if v == 0]
        if disabled:
            a.add("WARN", "rp-filter", "Sin validación IPv4 de ruta inversa en interfaces de salida",
                  ", ".join(disabled) + ": max(all, interfaz)=0; no es evidencia de ataque.",
                  "Valora rp_filter=2 (flexible) para esas interfaces, especialmente si usas VPN/libvirt. No protege frente a todo spoofing ni sustituye un firewall.")
        for key in ("fs.protected_hardlinks", "fs.protected_symlinks", "kernel.dmesg_restrict"):
            if read(key) == "0":
                a.add("WARN", key, "Endurecimiento local desactivado", key + "=0", "Revisa compatibilidad antes de establecer este parámetro a 1.")

    def accounts():
        roots = [p.pw_name for p in pwd.getpwall() if p.pw_uid == 0]
        if roots != ["root"]:
            a.add("FAIL", "uid-zero", "Cuentas UID 0 distintas de la cuenta root habitual", ", ".join(roots), "Revisa /etc/passwd y el origen de esas cuentas.")
        sockets = []
        for path in ("/run/docker.sock", "/run/podman/podman.sock"):
            p = Path(path)
            if not p.exists():
                continue
            st = p.stat()
            sockets.append(dict(path=path, mode=oct(stat.S_IMODE(st.st_mode))))
            if st.st_mode & 0o002:
                a.add("FAIL", "container-socket", "Socket de administración de contenedores escribible por cualquiera", path, "Restringe sus permisos; el acceso puede equivaler a root.")
            elif os.access(p, os.W_OK) and os.getuid() != 0:
                a.add("WARN", "docker-root-equivalent", "Tu cuenta puede administrar el motor de contenedores del sistema", path, "Es un privilegio equivalente a root en Docker rootful: limita quién pertenece al grupo y qué programas ejecutas con tu cuenta.")
        a.inventory["container_sockets"] = sockets

    def updates():
        if shutil.which("apt"):
            rc, out, err = a.run(["apt", "list", "--upgradable"], timeout=3)
            names = [line.split("/", 1)[0] for line in out.splitlines() if "/" in line and "upgradable" in line]
            metadata = [p for p in Path("/var/lib/apt/lists").glob("*InRelease") if p.is_file()]
        elif shutil.which("xbps-install"):
            rc, out, err = a.run(["xbps-install", "-un"], timeout=3)
            names = [line.split()[0] for line in out.splitlines() if line.strip()]
            metadata = [p for pattern in ("*repodata*", "*/*repodata*") for p in Path("/var/db/xbps").glob(pattern) if p.is_file()]
        else:
            a.skip("Actualizaciones", "No hay apt ni xbps-install; sin evaluación del gestor de paquetes."); return
        if rc:
            a.skip("Actualizaciones", err or "consulta local fallida"); return
        a.inventory["updates_available"] = names
        important = [n for n in names if any(x in n.lower() for x in ("openssh", "openssl", "libssl", "linux-image", "linux6", "sudo", "firefox", "chromium", "libc6", "glibc", "networkmanager"))]
        if important:
            a.add("WARN", "updates-important", "Actualizaciones pendientes de componentes sensibles",
                  ", ".join(important[:15]), "Actualiza desde los repositorios de tu distribución; esta comprobación no atribuye CVEs ni consulta Internet.")
        if not metadata:
            a.skip("Vigencia del catálogo", "No se encontró metadata de paquetes con fecha verificable.")
        else:
            age = (time.time() - max(p.stat().st_mtime for p in metadata)) / 86400
            if age > 7:
                a.add("WARN", "updates-stale", "Catálogo local de actualizaciones antiguo", f"Última metadata: {age:.0f} días", "Refresca el índice con tu gestor de paquetes; el escaneo nunca lo descarga ni instala nada.")

    for name, function in (("listeners", listeners), ("permisos sensibles", permissions),
                           ("SSH efectivo", ssh_config), ("cortafuegos", firewall),
                           ("sysctl activos", sysctls), ("cuentas y contenedores", accounts),
                           ("actualizaciones locales", updates)):
        a.check(name, function)
    return a.result()


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--json", action="store_true")
    p.add_argument("--verbose", action="store_true")
    p.add_argument("--no-color", action="store_true", help="compatibilidad; la salida nunca usa ANSI")
    args = p.parse_args()
    raise SystemExit(standalone(audit(), args.json, args.verbose))
