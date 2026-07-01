#!/usr/bin/zsh

# =============================================================================
# Authors:      Roman Garcia Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Sun 14. Dec 2025
#
# Purpose:      Launch tokamak-gif in a popup window 
# =============================================================================


mpv --loop=inf --no-border --geometry=800x800+100+100 --ontop --title="l_tokamak" ~/Code/gnuplot/tokamak.webm
