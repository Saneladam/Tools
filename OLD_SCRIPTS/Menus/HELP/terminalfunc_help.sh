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
    ["fastfetch"]="prints the computer specifications"
    ["astroterm"]="prints the real-time constellations"
    ["pokeget"]="print a pokemon"
    ["crontab -e"]="goes to the cron configuration file"
    ["curl wttr.in"]="shows the weather report (see output customization)"
    ["ollama run"]="coder - guru - nuclear"
    ["ani-cli"]="watch anime"
    ["phub-cli"]="watch p..."
    ["llm-checker"]="sync check recommend"
    ["yt-dlp -U"]="updates the cookies of yt-dlp"
    ["chafa"]="displays image on terminal"
    ["theme"]="updates the theme type (light/dark)"
    ["transmission-cli"]="get torrents"
    ["jp2a"]="get images into ascii art"
    ["tailscale up/down"]="enables tailscale ssh connection"
    ["mail"]="echo message | mail -s 'Title' -a file.pdf target@gmail.com"
    ["splurp -p"]="gets the pixel's coordinate of the  cursor"
    ["grim"]="take a screenshot"
    ["slurp"]="get the pixel coordinates"
    ["brightnessctl"]="set 50% / +10% / 200"
    ["cronboard"]="edits the crontab -e"
    ["daylight"]="shows the daylight hors"
    ["kalker"]="scientific calculator"
    ["countryfetch"]="fetcher of country"
    ["lavat"]="lava lamp in terminal"
    ["camera"]="opens the camera of the laptop, s to take screenshot"
    ["wf-recorder"]="records the screen"
    ["termipedia"]="opens wikipedia on therminal"
    ["wikiman"]="opens the arch-wiki"
)

# Build list for dmenu: "KEY  →  DESCRIPTION"
Choices=""
for Key in "${!ScriptMap[@]}"; do
    Choices+="$Key  ==>  ${ScriptMap[$Key]}\n"
done

Choice=$(printf "%b" "$Choices" | dmenu -c -l 50 -i -p "Terminal: Commands")

exit 0

