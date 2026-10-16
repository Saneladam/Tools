"""Small standard-library-only primitives for bounded, read-only audits."""
from __future__ import annotations

import datetime as dt
import ipaddress
import json
import os
from pathlib import Path
import re
import socket
import subprocess
import time


def clean(value):
    return re.sub(r"[\x00-\x1f\x7f-\x9f]", " ", str(value)).strip()


def host_name():
    return re.sub(r"[^a-zA-Z0-9_.-]", "_", socket.gethostname())


def report_dir():
    # Always under ~/Logs, independent of XDG_CACHE_HOME / XDG_STATE_HOME.
    return Path.home() / "Logs" / "security" / host_name()


def load_json(path, default=None):
    try:
        return json.loads(Path(path).read_text())
    except (OSError, ValueError):
        return default


def load_policy():
    root = Path.home() / "Tools/security"
    policy = load_json(root / "policy.json", {})
    host = load_json(root / "hosts" / (host_name() + ".json"), {})
    if not isinstance(policy, dict):
        policy = {}
    if isinstance(host, dict):
        policy.update(host)
    return policy


def atomic_write(path, data):
    import tempfile
    path = Path(path)
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=".security-", dir=path.parent)
    try:
        with os.fdopen(fd, "w") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


class Audit:
    def __init__(self, engine, budget=10):
        self.engine = engine
        self.started = time.monotonic()
        self.deadline = self.started + budget
        self.findings = []
        self.checked = []
        self.skipped = []
        self.inventory = {}

    def add(self, level, code, title, evidence, action=""):
        if any(f["id"] == code for f in self.findings):
            return
        self.findings.append(dict(level=level, id=code, title=clean(title),
                                  evidence=clean(evidence), action=clean(action)))

    def skip(self, check, reason):
        self.skipped.append({"check": check, "reason": clean(reason)})

    def run(self, argv, timeout=2):
        remaining = self.deadline - time.monotonic()
        if remaining <= 0:
            return 124, "", "presupuesto de tiempo agotado"
        try:
            p = subprocess.run(argv, capture_output=True, text=True, errors="replace",
                               timeout=min(timeout, remaining), check=False,
                               env={**os.environ, "LC_ALL": "C", "LANG": "C"})
            return p.returncode, p.stdout.strip(), p.stderr.strip()
        except (OSError, subprocess.TimeoutExpired) as exc:
            return 124 if isinstance(exc, subprocess.TimeoutExpired) else 127, "", str(exc)

    def check(self, name, function, *args):
        if time.monotonic() >= self.deadline:
            self.skip(name, "presupuesto de tiempo agotado")
            return
        try:
            function(*args)
            self.checked.append(name)
        except Exception as exc:
            self.skip(name, f"{type(exc).__name__}: {exc}")

    def result(self):
        return dict(engine=self.engine, findings=self.findings, checked=self.checked,
                    skipped=self.skipped, inventory=self.inventory,
                    duration_seconds=round(time.monotonic() - self.started, 3))


def endpoint(value):
    address, port = value.rsplit(":", 1)
    return address.strip("[]"), int(port)


def is_loopback(address):
    try:
        addr = ipaddress.ip_address(address.split("%", 1)[0])
        return addr.is_loopback or bool(getattr(addr, "ipv4_mapped", None) and addr.ipv4_mapped.is_loopback)
    except ValueError:
        return False


def parse_listeners(text):
    records = []
    for line in text.splitlines():
        parts = line.split()
        if len(parts) < 6 or parts[0] not in ("tcp", "udp"):
            continue
        try:
            address, port = endpoint(parts[4])
        except (ValueError, IndexError):
            continue
        process = re.search(r'users:\(\("([^"\x00]+)"', line)
        records.append(dict(protocol=parts[0], address=address, port=port,
                            process=process.group(1) if process else None))
    return records


def nm_fields(line):
    """nmcli terse fields: escaped colons and backslashes are not delimiters."""
    fields, buf, escaped = [], [], False
    for char in line:
        if escaped:
            buf.append(char)
            escaped = False
        elif char == "\\":
            escaped = True
        elif char == ":":
            fields.append("".join(buf)); buf = []
        else:
            buf.append(char)
    if escaped:
        buf.append("\\")
    return fields + ["".join(buf)]


def text_report(report, verbose=False):
    counts = {level: sum(f["level"] == level for f in report["findings"])
              for level in ("FAIL", "WARN")}
    skipped = report.get("skipped", [])
    lines = [f"Seguridad — {report.get('host', host_name())} — {report.get('finished_at', '')}",
             f"FAIL={counts['FAIL']} WARN={counts['WARN']} | "
             f"{len(report.get('checked', []))} comprobaciones ejecutadas; {len(skipped)} no verificadas."]
    for f in sorted(report["findings"], key=lambda f: (f["level"] != "FAIL", f["id"])):
        lines.append(f"{f['level']}\t{f['title']}\t{f['evidence']}")
        if f.get("action"):
            lines.append(f"  Acción: {f['action']}")
    if not report["findings"]:
        lines.append("Sin hallazgos en las comprobaciones ejecutadas; no equivale a sistema libre de amenazas.")
    if skipped:
        lines.append("No verificado:")
        lines.extend(f"  - {s['check']}: {s['reason']}" for s in skipped)
    if verbose:
        lines += ["Inventario (evidencia, no evaluación de seguridad):",
                  json.dumps(report.get("inventory", {}), ensure_ascii=False, indent=2)]
    lines.append("Límite: auditoría local puntual; no detecta todo malware ni demuestra exposición desde Internet.")
    return "\n".join(lines) + "\n"


def exit_status(report):
    return 2 if any(f["level"] == "FAIL" for f in report["findings"]) else int(bool(report["findings"]))


def standalone(result, as_json=False, verbose=False):
    result.update(host=host_name(), finished_at=dt.datetime.now().astimezone().isoformat(timespec="seconds"))
    print(json.dumps(result, ensure_ascii=False, indent=2) if as_json else text_report(result, verbose), end="\n" if as_json else "")
    return exit_status(result)
