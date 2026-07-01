#!/bin/bash

# =============================================================================
# Authors:      Roman Garcia Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Thu 04. Dec 2025
#
# Purpose:      Run a list of all the available manuals and prints the selected
#               with zathura.
# =============================================================================

man -k . | dmenu -c -l 40 -nb '#ffffff' -nf '#000000' -sb '#ffffff' -sf '#ff0000' -p "Manuals" | awk '{print $1}' | xargs -r man -Tpdf  | zathura - || exit

