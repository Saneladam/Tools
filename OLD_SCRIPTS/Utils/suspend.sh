#!/bin/bash

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Fri 01. May 2026
#
# Purpose:      Suspends the computer
# =============================================================================

if systemctl is-enabled suspend.target 2>/dev/null | grep -q masked; then
  notify-send "Suspend blocked" "NO-SLEEP mode is active"
else
  swaylock
fi
