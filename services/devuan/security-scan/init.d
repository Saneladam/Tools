#!/bin/sh
### BEGIN INIT INFO
# Provides:          security-scan
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs $network
# Should-Start:      network-manager dbus slim ssh docker
# Should-Stop:       network-manager dbus slim ssh docker
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Bounded defensive snapshot before shutdown
### END INIT INFO
# Root-owned installed copy. Never execute user-owned audit code as root.
PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH
set -u
[ -r /etc/default/security-scan ] || exit 0
. /etc/default/security-scan
account="$(getent passwd "$SECURITY_USER")" || exit 1
user_home="$(printf '%s\n' "$account" | cut -d: -f6)"
user_shell="$(printf '%s\n' "$account" | cut -d: -f7)"
case "$user_home" in /*) ;; *) exit 1 ;; esac

snapshot()
{
    # Both halves have an independent hard deadline; no network downloads.
    timeout 9 /usr/local/libexec/security-system-facts "$SECURITY_USER" |
        timeout -k 2 20 runuser -u "$SECURITY_USER" -- env -i \
            HOME="$user_home" USER="$SECURITY_USER" LOGNAME="$SECURITY_USER" \
            SHELL="$user_shell" PATH="$user_home/Tools/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
            /usr/bin/python3 "$user_home/Tools/bin/security-scan" \
            --system-facts-stdin --reason "$1" --quiet
    result=$?
    # Findings (1/2) are audit results, not init failures. Timeouts remain visible.
    case "$result" in
        0|1|2) return 0 ;;
        *)
            runuser -u "$SECURITY_USER" -- env -i HOME="$user_home" PATH=/usr/bin:/bin \
                sh -c 'printf "[%s] Snapshot failed/timeout; last complete report retained.\n" "$(date -Is)" >> "$HOME/Logs/security-service.log"'
            return "$result"
            ;;
    esac
}

case "${1:-}" in
    start)
        install -d -m 755 /run/security-scan
        touch /run/security-scan/armed
        if [ -f /run/security-scan/closing ]; then
            mv /run/security-scan/closing /run/security-scan/last-closing
        fi
        ;;
    stop)
        [ -f /run/security-scan/armed ] || exit 0
        touch /run/security-scan/closing
        snapshot shutdown
        result=$?
        mv /run/security-scan/armed /run/security-scan/last-stop
        exit "$result"
        ;;
    scan) snapshot manual ;;
    status)
        if [ -f /run/security-scan/armed ]; then
            printf 'security-scan: armado para apagado/reinicio; no es un daemon.\n'
        else
            printf 'security-scan: no armado.\n'; exit 3
        fi
        ;;
    restart|force-reload) "$0" start ;;
    *) printf 'Usage: %s {start|stop|status|scan}\n' "$0"; exit 2 ;;
esac
