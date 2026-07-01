#!/bin/bash

# Carpeta donde están los scripts
ScriptsDir="$HOME/Scripts/Menus/HELP"

# Array asociativo: "Palabra clave" -> "Nombre del script"
declare -A ScriptMap=(
    ["Markdown Commands"]="markdown_help.sh"
    ["Terminal Commands"]="terminalfunc_help.sh"
    ["Mango Tags"]="mango_show_help.sh"
    ["Zathura Tags"]="zathura_help.sh"
    ["Nvim Shortcuts"]="nvim_help.sh"
)

# Mostrar opciones de dmenu
Choice=$(printf "%s\n" "${!ScriptMap[@]}" | dmenu -c -nb '#ffffff' -nf '#000000' -sb '#ffffff' -sf '#ff0000'  -l 10 -i -p "Select action:")

# Salir si no se selecciona nada
[[ -z "$Choice" ]] && exit 0

# Obtener script correspondiente
ScriptPath="$ScriptsDir/${ScriptMap[$Choice]}"

# Ejecutar el script
if [[ -f "$ScriptPath" && -x "$ScriptPath" ]]; then
    # setsid -f kitty -e "$ScriptPath" >/dev/null 2>&1 &
    $ScriptPath >/dev/null 2>&1 &
else
    notify-send "Error" "Script ${ScriptMap[$Choice]} not found"
fi
