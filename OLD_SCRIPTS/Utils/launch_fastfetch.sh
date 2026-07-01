#!/usr/bin/zsh

# =============================================================================
# Authors:      Roman Garcia Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Sun 14. Dec 2025
#
# Purpose:      Launch fastfetch in a popup window 
# =============================================================================


pkill -x fastfetch 2>/dev/null
sleep 0.2

kitty --title "l_fastfetch" --hold fastfetch
