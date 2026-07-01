#!/bin/bash

# =============================================================================
# Authors:      Roman Garcia Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Fri 21 Nov 2025
# 
# Purpose:      Show terminal functionalities cheatsheet via dmenu.
# =============================================================================

# Declare associative array: KEYBIND → DESCRIPTION
declare -A ScriptMap=(
    ["i"]="recolor"
    ["r"]="reload" 
    ["p"]="print" 
    ["R"]="rotate" 
    ["K"]="zoom in"
    ["J"]="zoom out" 
    ["u"]="scroll half-up"
    ["d"]="scroll half-down"
    ["D"]="toggle_page_mode"
)

# Build list for dmenu: "KEY  →  DESCRIPTION"
Choices=""
for Key in "${!ScriptMap[@]}"; do
    Choices+="$Key  ==>  ${ScriptMap[$Key]}\n"
done

Choice=$(printf "%b" "$Choices" | dmenu -c -l 50 -i -p "Terminal: Commands")

exit 0









