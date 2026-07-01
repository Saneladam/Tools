#!/bin/bash

# =============================================================================
# Authors:      Roman Garcia Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Thu 04. Dec 2025
#
# Purpose:      Run a list of all the available lectures to read and shows the
#               chosen with zathura.
# =============================================================================

TERMINAL="kitty"
README_DIR="/home/akash/Lecture/README.md"
folders=$HOME/Lecture/*/

edit_README () { \
        nvim ${folder}README.md
  }

selected () { \
  choice=$(echo -e "README\n$(command ls -t1 ${folders}*.pdf)" | dmenu -c -nb '#ffffff' -nf '#000000' -sb '#ffffff' -sf '#ff0000' -l 25 -i -p "Select the Reading Material: ") || exit 1
  case $choice in
          README) setsid -f "$TERMINAL" -e nvim "$README_DIR" >/dev/null 2>&1 ;;
          *.pdf) zathura "$choice" ;;
          *) exit ;;
  esac
}

selected
