#!/bin/bash

# Carpeta donde están los scripts
ScriptsDir="$HOME/Scripts/GetFrom"

# Array asociativo: "Palabra clave" -> "Nombre del script"
declare -A ScriptMap=(
    # ["Playlist Add"]="playlist_add_current.sh"
    # ["Youtube Get"]="get_yt_music.sh"
    ["Youtube Music Single"]="test_getYTMusic.sh -t s"
    ["Youtube Music Playlist"]="test_getYTMusic.sh -t p"
    ["Youtube Video Single"]="get_yt_video.sh"
    ["Youtube Video Playlist"]="get_yt_playlistvideo.sh"
)


# Mostrar opciones de dmenu
Choice=$(printf "%s\n" "${!ScriptMap[@]}" | dmenu -c -l 10 -nb '#000000' -nf '#ffffff' -sb '#000000' -sf '#ffffff' -i -p "Select action:")

# Salir si no se selecciona nada
[[ -z "$Choice" ]] && exit 0

# Obtener script correspondiente
ScriptPath="$ScriptsDir/${ScriptMap[$Choice]}"

# # Ejecutar el script
# if [[ -f "$ScriptPath" && -x "$ScriptPath" ]]; then
#     # setsid -f kitty -e "$ScriptPath" >/dev/null 2>&1 &
#     $ScriptPath >/dev/null 2>&1 &
# else
#     notify-send "Error" "Script ${ScriptMap[$Choice]} not found or not executable"
# fi

$ScriptPath >/dev/null 2>&1 &

