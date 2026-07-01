#!/bin/bash

# =============================================================================
# Authors:      Roman Garcia Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Wed 19 Nov 2025
#
# Purpose:      Show MangoWM tag/layout cheatsheet via dmenu.
# =============================================================================

# Declare associative array: KEYBIND → DESCRIPTION
declare -A ScriptMap=(
    ["SUPER+CTRL+l"]="Set layout: witch layout"
    ["SUPER+CTRL+s"]="Set layout: scroller"
    ["SUPER+CTRL+t"]="Set layout: tile"
    ["SUPER+CTRL+g"]="Set layout: grid"
    ["SUPER+CTRL+d"]="Set layout: deck"
    ["SUPER+CTRL+m"]="Set layout: monocle"
    ["SUPER+CTRL+c"]="Set layout: center_tile"
    ["SUPER+CTRL+y"]="Set layout: vertical_tile"
    ["SUPER+CTRL+v"]="Set layout: vertical_scroller"
    ["SUPER+SHIFT+c"]="Set layout: center window"
    ["CTRL+SHIFT+backslash"]="Set layout opt: toggleoverview,"
    ["CTRL+backslash"]="Set layout opt: togglefloating,"
    ["CTRL+F10"]="Set layout opt: togglemaximizescreen,"
    ["NONE+F10"]="Set layout opt: togglefullscreen,"
    ["CTRL+SHIFT+F10"]="Set layout opt: togglefakefullscreen,"
    ["CTRL+F11"]="Set layout opt: minimized,"
    ["NONE+F11"]="Set layout opt: toggleoverlay,"
    ["CTRL+SHIFT+F11"]="Set layout opt: restore_minimized"
    ["CTRL+F12"]="Set layout opt: toggle_scratchpad"
    ["CTRL+ALT+x"]="Set layout opt: switch_proportion_preset,"

    ["SUPER+Return"]="Launch app: kitty"
    ["SUPER+q"]="Launch app: killclient"
    ["SUPER+d"]="Launch app: ranger "
    ["SUPER+e"]="Launch app: librewolf"
    ["SUPER+s"]="Launch app: ncspot"
    ["SUPER+SHIFT+s"]="Launch app: rmpc"
    ["SUPER+F1"]="Launch app: kitty --hold fastfetch"
    ["SUPER+n"]="Launch app: nvim"
    ["SUPER+c"]="Launch app: calcurse"
    ["SUPER+v"]="Launch app: virt-manager"
    ["SUPER+m"]="Launch app: neomutt"
    ["SUPER+x"]="Launch app: sc-im"
    ["SUPER+w"]="Launch app: impala"
    ["SUPER+g"]="Launch app: gimp"
    ["SUPER+i"]="Launch app: inkspace"
    ["SUPER+ALT+r"]="Execute script: reload_config"
    ["SUPER+ALT+s"]="Execute script: ~/Scripts/snip.sh"
    ["SUPER+ALT+g"]="Execute script: ~/Scripts/Menus/Music_Options.sh"
    ["SUPER+ALT+h"]="Execute script: ~/Scripts/Menus/HELP/Help_Options.sh"
    ["SUPER+ALT+m"]="Execute script: ~/Scripts/Menus/mansplain.sh"
    ["SUPER+ALT+n"]="Execute script: ~/Scripts/Menus/notes.sh"
    ["SUPER+ALT+l"]="Execute script: ~/Scripts/Menus/lecture.sh"
    ["SUPER+ALT+d"]="Execute script: ~/Scripts/Notifications/define.sh"
    ["SUPER+ALT+Escape"]="Execute script: ~/Scripts/Menus/power_options.sh"

    ["SUPER+ALT+LR"]="Change to tag L-R"
    ["SUPER+09"]="Change to tag 0-9"
    ["SUPER+SHIFT+09"]="Window move tag"
    ["SUPER+Alt+09"]="Window move tagsilent"
    # monitor switch
    ["alt+shift+Right"]="focusmon,right"
    ["SUPER+alt+shift+Left"]="tagmon,left"
    ["SUPER+alt+shift+Right"]="tagmon,right"
    # gaps
    ["ALT+SHIFT+Z"]="incgaps,-1"
    ["ALT+SHIFT+R"]="togglegaps"
    # movewin
    ["CTRL+SHIFT+j"]="movewin,+0,+50"
    ["CTRL+SHIFT+h"]="movewin,-50,+0"
    ["CTRL+SHIFT+l"]="movewin,+50,+0"
    # resizewin
    ["CTRL+ALT+hjkl"]="Window resize"
    # Mouse Button Bindings
    # NONE mode key only work in ov mode
    ["mouseSUPER+btn_left"]="moveresize,curmove"
    ["mouseSUPER+btn_middle"]="togglemaximizescreen,0"
    ["mouseSUPER+btn_right"]="moveresize,curresize"
    ["mouseNONE+btn_left"]="toggleoverview,-1"
    ["mouseNONE+btn_right"]="killclient,0"

)

# Build list for dmenu: "KEY  →  DESCRIPTION"
Choices=""
for Key in "${!ScriptMap[@]}"; do
    Choices+="$Key  ==>  ${ScriptMap[$Key]}\n"
done

Choice=$(printf "%b" "$Choices" | dmenu -c -l 58 -i -p "Mango: Tag & Layout Commands")

exit 0

