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

La auditoría está documentada en [security/README.md](../security/README.md).
Incluye los motores local y WiFi pasivo, con hallazgos, acciones y cobertura.
Informes: `~/Logs/security/HOST/latest.{log,json}`. No hay escaneo activo de LAN.

En Devuan/SysVinit, `devuan/activate .../security-scan` instala un gancho de
apagado/reinicio; requiere sudo. En XFCE se instala también el autostart de usuario:

```sh
~/Tools/bin/security-session --install-desktop
~/Tools/services/devuan/activate ~/Tools/services/devuan/security-scan
```

En Void, `void/activate .../security-scan` copia la definición a `/etc/sv` y la
activa en `/var/service`; el estado de runit ya no vive dentro de Tools/Syncthing.
Las auditorías se ejecutan sin root y el HOME se resuelve para el usuario correcto.
La instantánea final runit/logout es best-effort; se conservan también periódicas.

`security-show --once -m 8` muestra el último informe en la primera terminal
interactiva de cada sesión (también si el informe es de hoy).

## Devuan con SysVinit

El servicio de seguridad se instala en `/etc/init.d/security-scan`, con enlaces
en rc0/rc1/rc6. No se requiere systemd ni runit. El resto de definiciones runit
se conserva para equipos que realmente usen ese init; no se convierte session-sync.

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
