# Services in `Tools`

The repository contains portable runit service definitions. The common
repository logic remains in `Tools/bin/session`; only activation differs by
operating system.

All service output is written to:

```text
~/Logs/session-service.log
```

## Devuan

```sh
~/Tools/services/devuan/activate \
    ~/Tools/services/devuan/session-sync
```

The activator checks, in order:

```text
/var/service
/etc/service
/etc/runit/runsvdir/default
```

## Void

```sh
~/Tools/services/void/activate \
    ~/Tools/services/void/session-sync
```

Void's activator links the service into:

```text
/var/service/session-sync
```

## Lifecycle

The `run` script writes output to `~/Logs/session-service.log`, runs
`~/Tools/bin/session start` once, stays alive as a runit service, and runs
`~/Tools/bin/session end` when runit sends `TERM`, `INT` or `HUP`.

An abrupt power loss cannot run the final hook. The next normal start still
executes `session start`, and `session` reports repository pull failures or
local/conflicting states instead of aborting the other repositories.

The same activation interface works for future service directories:

```sh
~/Tools/services/devuan/activate ~/Tools/services/devuan/service-a
~/Tools/services/void/activate ~/Tools/services/void/service-a
```
