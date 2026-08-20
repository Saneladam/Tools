#!/bin/bash

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Wed 24. Jun 2026
#
# Purpose:      Configures the idle time of swayidle
# =============================================================================

exec swayidle -w \
    timeout 600  "$HOME/.config/sway/lock.sh" \
    timeout 1200 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
    before-sleep "$HOME/.config/sway/lock.sh"
