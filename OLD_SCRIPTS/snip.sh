#! /bin/bash

# =============================================================================
# Authors:      Roman Garcia Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Sat 15. Nov 2025
#
# Purpose:      Take a screenshot 
# =============================================================================

SNAP_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SNAP_DIR"
FILE="$SNAP_DIR/snip_$(date +%Y%m%d_%H%M%S).png"

grim -g "$(slurp)" "$FILE"
wl-copy < "$FILE"

notify-send "Screenshot saved" "$FILE"
