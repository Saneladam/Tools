# Services in `Tools`

The repository contains portable runit service definitions. Shared logic lives
under `Tools/bin/`; only activation differs by operating system.

## Activate all services

Each OS directory has an `activate` script. With **no arguments** or `--all`,
it activates every sibling service directory that contains an executable `run`.
With one `SERVICE_DIRECTORY` argument, it activates only that service
(backward compatible).

```sh
# Void — all services in this directory
~/Tools/services/void/activate
~/Tools/services/void/activate --all

# Void — one service
~/Tools/services/void/activate ~/Tools/services/void/session-sync
~/Tools/services/void/activate ~/Tools/services/void/security-scan

# Devuan — same interface
~/Tools/services/devuan/activate
~/Tools/services/devuan/activate --all
~/Tools/services/devuan/activate ~/Tools/services/devuan/session-sync
```

If `/var/service` (or the Devuan active dir) is not writable, `activate` tries
`sudo -n ln -sfn …`. When that fails, it prints the exact `sudo ln -sfn …`
command to run as root.

## Services

### session-sync

- **Start:** `~/Tools/bin/session start` (system check, git pull, notes)
- **Stop (TERM/INT/HUP):** `~/Tools/bin/session end` (save, git push)
- **Service log:** `~/Logs/session-service.log`

### security-scan

Defensive **local** audit only (`~/net_selfcheck.py`). Does **not** run
`wifi_selfcheck` or any WiFi/LAN deep scan.

- **Start:** show yesterday’s report (`~/Tools/bin/security-show`)
- **Stop (TERM/INT/HUP):** run scan and save dated report (`~/Tools/bin/security-scan`)
- **Reports:** `~/Logs/security/YYYY-MM-DD.log`, `latest.log`, optional `yesterday` symlink
- **Service log:** `~/Logs/security-service.log`

Manual:

```sh
~/Tools/bin/security-scan       # write today’s report
~/Tools/bin/security-show       # full yesterday report
~/Tools/bin/security-show -m 10 # TTY/login: only WARN/FAIL, max 10 lines
```

Interactive login shells (bash/zsh on a real TTY or login shell) and
`session start` call `security-show -m 10`. The runit service start still
prints the full yesterday report into `~/Logs/security-service.log`.

## Devuan active directories (checked in order)

```text
/var/service
/etc/service
/etc/runit/runsvdir/default
```

## Void active directory

```text
/var/service
```

## Lifecycle notes

An abrupt power loss cannot run the stop hook. The next normal start still
runs the start hook. `session` reports repository pull failures without
aborting the other repositories.

If runit activation needs root and is not yet linked, the same security
behavior is also wired into `~/Tools/bin/session` (start → show yesterday;
end → run scan) so it stays live without waiting for `/var/service`.
