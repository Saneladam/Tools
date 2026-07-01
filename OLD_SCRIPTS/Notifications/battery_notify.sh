#!/bin/bash

BATTERY_PATH="/sys/class/power_supply"
BAT=$(ls "$BATTERY_PATH" | grep -E '^BAT[0-9]+' | head -n 1)

CHARGE=$(cat "$BATTERY_PATH/$BAT/capacity")
STATUS=$(cat "$BATTERY_PATH/$BAT/status")

STATE_FILE="/tmp/battery_last_state"

if [[ -f $STATE_FILE ]]; then
    LAST_STATE=$(cat "$STATE_FILE")
else
    LAST_STATE=""
fi

notify_once() {
    local urgency="$1"
    local message="$2"
    local state="$3"
    if [[ "$LAST_STATE" != "$state" ]]; then
        dunstify -u "$urgency" "Battery Status" "$message"
        echo "$state" > "$STATE_FILE"
    fi
}

if [[ "$STATUS" == "Charging" ]]; then
    if [[ $CHARGE -lt 95 ]]; then
        notify_once low "⚡ Charging: ${CHARGE}%" "charging"
    elif [[ $CHARGE -eq 95 ]]; then
        notify_once low "⚡ Charging: 95%" "charging95"
    elif [[ $CHARGE -ge 100 ]]; then
        notify_once low "Battery fully charged" "full"
    fi
else
    if [[ $CHARGE -le 5 ]]; then
        notify_once critical "⚠ Critical battery level: ${CHARGE}%" "low5"
    elif [[ $CHARGE -le 10 ]]; then
        notify_once critical "⚠ Very low battery: ${CHARGE}%" "low10"
    elif [[ $CHARGE -le 25 ]]; then
        notify_once normal "Battery low: ${CHARGE}%" "low25"
    elif [[ $CHARGE -le 50 ]]; then
        notify_once normal "Battery at 50%" "half"
    fi
fi
