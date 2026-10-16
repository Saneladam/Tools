"""Regression tests use fixtures/temp homes, never change real security settings."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import runpy
import sys
import tempfile
import subprocess
from types import SimpleNamespace
import unittest
from unittest.mock import patch

BIN = Path(__file__).resolve().parents[1] / "bin"
sys.path.insert(0, str(BIN))
from security_core import Audit, atomic_write, is_loopback, nm_fields, parse_listeners
from net_selfcheck import effective_rp_filter, protected_by_ancestor
from wifi_selfcheck import connected, encryption_findings


class ParsingTests(unittest.TestCase):
    def test_disconnected_is_not_connected(self):
        self.assertFalse(connected("disconnected"))
        self.assertTrue(connected("connected"))
        self.assertTrue(connected("connected (externally)"))

    def test_nm_colons_and_backslashes(self):
        self.assertEqual(nm_fields(r"yes:wlan0:aa\:bb\:cc:My\:WiFi:WPA2"),
                         ["yes", "wlan0", "aa:bb:cc", "My:WiFi", "WPA2"])

    def test_explicit_lan_binding_not_mistaken_for_loopback(self):
        line = 'tcp LISTEN 0 128 192.168.1.2:11434 0.0.0.0:* users:(("ollama",pid=5,fd=3))'
        item = parse_listeners(line)[0]
        self.assertEqual(item["port"], 11434)
        self.assertFalse(is_loopback(item["address"]))
        self.assertEqual(item["process"], "ollama")

    def test_ipv6_and_mapped_loopback(self):
        self.assertTrue(is_loopback("::1"))
        self.assertTrue(is_loopback("::ffff:127.0.0.1"))
        self.assertFalse(is_loopback("::"))
        self.assertFalse(is_loopback("*"))
        self.assertEqual(parse_listeners("tcp LISTEN 0 128 [::]:22 [::]:*")[0]["port"], 22)

    def test_rp_filter_uses_interface_not_default(self):
        self.assertEqual(effective_rp_filter("0", "2"), 2)
        self.assertEqual(effective_rp_filter("1", "0"), 1)
        self.assertEqual(effective_rp_filter("0", "0"), 0)

    def test_private_parent_protects_uv_lock(self):
        with tempfile.TemporaryDirectory() as directory:
            cache = Path(directory) / ".cache"
            cache.mkdir(mode=0o700)
            lock = cache / ".lock"
            lock.touch(mode=0o666)
            self.assertTrue(protected_by_ancestor(lock, os.getuid()))

    def test_wpa_psk_profile_is_not_proof_of_wpa2(self):
        a = Audit("test")
        encryption_findings(a, "wlan0", {}, "WPA1", {"802-11-wireless-security.key-mgmt": "wpa-psk"})
        self.assertTrue(any(f["id"].startswith("wifi-legacy") for f in a.findings))
        self.assertTrue(a.skipped)

    def test_open_and_wep_are_critical(self):
        for security in ("--", "WEP"):
            a = Audit("test")
            encryption_findings(a, "wlan0", {}, security, {"802-11-wireless-security.key-mgmt": "none"})
            self.assertTrue(any(f["level"] == "FAIL" for f in a.findings))

    def test_sae_is_not_reported_as_legacy(self):
        a = Audit("test")
        encryption_findings(a, "wlan0", {"wpa_state": "COMPLETED", "key_mgmt": "SAE", "pairwise_cipher": "CCMP"}, "WPA3", {})
        self.assertEqual(a.findings, [])
        self.assertEqual(a.skipped, [])

    def test_errors_are_coverage_gaps_not_clean_checks(self):
        a = Audit("test")
        a.check("broken", lambda: 1 / 0)
        self.assertFalse(a.checked)
        self.assertEqual(a.skipped[0]["check"], "broken")


class ReportTests(unittest.TestCase):
    def test_concurrent_scan_is_not_started(self):
        import fcntl
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {"HOME": directory}):
            from security_core import report_dir
            root = report_dir()
            root.mkdir(parents=True)
            with (root / ".scan.lock").open("a") as stream:
                fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
                result = subprocess.run([sys.executable, "-B", str(BIN / "security-scan")], capture_output=True, text=True, timeout=3)
                self.assertEqual(result.returncode, 0)
                self.assertIn("no se duplica", result.stdout)
                self.assertFalse((root / "latest.json").exists())

    def test_once_marker_is_per_session_on_real_tty(self):
        import pty
        import select
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {"HOME": directory}):
            from security_core import host_name, report_dir
            atomic_write(report_dir() / "latest.json", json.dumps(dict(host=host_name(), finished_at="2026-10-16T10:00:00+02:00", findings=[], skipped=[], checked=[], reason="test")))
            def show(session):
                master, slave = pty.openpty()
                proc = subprocess.Popen([sys.executable, "-B", str(BIN / "security-show"), "--once", "-m", "2"],
                    stdin=slave, stdout=slave, stderr=slave,
                    env={**os.environ, "XDG_SESSION_ID": session})
                os.close(slave)
                data = b""
                while select.select([master], [], [], 3)[0]:
                    try:
                        chunk = os.read(master, 65536)
                    except OSError:
                        break
                    if not chunk:
                        break
                    data += chunk
                proc.wait(timeout=3)
                os.close(master)
                return data.decode()
            self.assertIn("Seguridad", show("session-a"))
            self.assertEqual(show("session-a"), "")
            self.assertIn("Seguridad", show("session-b"))

    def test_atomic_permissions(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "latest.json"
            atomic_write(path, '{"schema": 1}')
            self.assertEqual(json.loads(path.read_text())["schema"], 1)
            self.assertEqual(path.stat().st_mode & 0o777, 0o600)

    def test_full_runner_and_today_view(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {"HOME": directory}):
            scan = runpy.run_path(str(BIN / "security-scan"))["main"]
            fixture = dict(engine="fake", findings=[], checked=["fixture"], skipped=[dict(check="firewall", reason="sin permisos")], inventory={})
            def fake_engine(_):
                return SimpleNamespace(audit=lambda *_: fixture)
            scan.__globals__["engine"] = fake_engine
            with patch.object(sys, "argv", ["security-scan", "--quiet", "--reason", "test"]):
                self.assertEqual(scan(), 0)
            from security_core import report_dir
            path = report_dir() / "latest.json"
            data = json.loads(path.read_text())
            self.assertEqual(data["reason"], "test")
            self.assertTrue(data["skipped"])
            show = runpy.run_path(str(BIN / "security-show"))["main"]
            output = io.StringIO()
            with patch.object(sys, "argv", ["security-show", "-m", "3"]), contextlib.redirect_stdout(output):
                self.assertEqual(show(), 0)
            self.assertIn("no verificados", output.getvalue())
            self.assertIn("test", output.getvalue())

    def test_invalid_report_never_shown_as_clean(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {"HOME": directory}):
            from security_core import report_dir
            atomic_write(report_dir() / "latest.json", "traceback")
            show = runpy.run_path(str(BIN / "security-show"))["main"]
            output = io.StringIO()
            with patch.object(sys, "argv", ["security-show", "-m", "3"]), contextlib.redirect_stdout(output):
                self.assertEqual(show(), 1)
            self.assertNotIn("Sin hallazgos", output.getvalue())


if __name__ == "__main__":
    unittest.main()
