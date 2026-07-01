#!/bin/bash

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Sat 21. Mar 2026
#
# Purpose:      Launches Cava
# =============================================================================

pkill -x cava 2>/dev/null
sleep 0.2

kitty --title "l_cava" -e cava
