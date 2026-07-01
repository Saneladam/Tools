#!/bin/bash

# =============================================================================
# Authors:      Roman Garcia Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Thu 04. Dec 2025
#
# Purpose:      Select between different shutdown options.
# =============================================================================

PID_FILE="$HOME/Logs/JOBS/nosleep_pid"

get_mode() {
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "NO-SLEEP"
  else
    echo "NORMAL"
  fi
}

start_nosleep() {
  systemd-inhibit --what=sleep --why="Manual NO-SLEEP mode" sleep infinity &
  echo $! > "$PID_FILE"
  notify-send "NO-SLEEP enabled" "System will not suspend"
}

stop_nosleep() {
  if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null
    rm -f "$PID_FILE"
    notify-send "Sleep enabled" "System can suspend normally"
  fi
}

toggle_sleep() {
  if [ "$(get_mode)" = "NO-SLEEP" ]; then
    stop_nosleep
  else
    start_nosleep
  fi
}

MODE=$(get_mode)

# choice=$(echo -e "Mode: $MODE\n---\nToggle Sleep Mode\nSuspend\nReboot\nShut Down" | dmenu -c -l 10 -p "Power Menu") || exit 1

# case "$choice" in
#   "Toggle Sleep Mode")
#     toggle_sleep
#     ;;
#   "Suspend")
#     systemctl suspend
#     ;;
#   "Reboot")
#     systemctl reboot
#     ;;
#   "Shut Down")
#     systemctl poweroff
#     ;;
# esac

TOGGLE_LABEL="Toggle Sleep (now: $MODE)"

choice=$(printf "%s\nSuspend\nReboot\nShut Down" "$TOGGLE_LABEL" \
  | dmenu -c -l 10 -p "Power Menu") || exit 1

case "$choice" in
  "$TOGGLE_LABEL")
    toggle_sleep
    ;;
  "Suspend")
    systemctl suspend
    ;;
  "Reboot")
    systemctl reboot
    ;;
  "Shut Down")
    systemctl poweroff
    ;;
esac
