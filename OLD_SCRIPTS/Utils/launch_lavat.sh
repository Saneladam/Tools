#!/bin/bash

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Sat 21. Mar 2026
#
# Purpose:      Launches Cava
# =============================================================================

pkill -x lavat 2>/dev/null
sleep 0.2

kitty --title "l_lavat" -e lavat -g -G -c 0000FF -k FF0000 -C
