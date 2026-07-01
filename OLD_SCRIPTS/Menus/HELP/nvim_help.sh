#!/bin/bash

# =============================================================================
# Authors:      Roman Garcia Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Fri 21 Nov 2025
# 
# Purpose:      Show nvim shortcut cheatsheet via dmenu.
# =============================================================================

# Declare associative array: KEYBIND → DESCRIPTION
declare -A ScriptMap=(
    [":Goyo"]="Poem Mode"
    [":Mason"]="View lenguages"
    [":PlugInstall"]="Install Plugins"
    ["F1"]="Chech errors"
    ["F2"]="Set invnumber"
    ["F3"]="Set relativenumber"
    ["F4"]="shellcheck/black"
    ["F5"]="python/bash execute"
    ["F6"]="setlocal spell! spelllang:en_us"
    ["F7"]="set spelllang:es"
    # ["F8"]=""
    # ["F9"]=""
    # ["F10"]=""
    # ["F11"]=""
    # ["F12"]=""
    ["]s"]="ir al siguiente error ortográfico"
    ["[s"]="ir al anterior"
    ["zg"]="agregar palabra al diccionario"
    ["zw"]="marcar palabra como incorrecta"
    ["zu"]="deshacer zg/zw"
    ["]d"]="ir al siguiente error"
    ["[d"]="ir al anterior"

    ["<C-n>"]="Abrir Oil en panel lateral"
    ["\n"]="Abrir Oil en el buffer actual"
    [":e ."]="Explorar actual (comando nvim nativo)"
    ["\ff"]="Find Files"
    ["\fl"]="Find Lines"
    ["\fb"]="Find Buffers"
    ["gc"]="Comentar selección"
    ["S*"]="Envuelve selección con *"
    ["ysiw*"]="Rodear palabra con *"
    ["cs*#"]="Cambiar delimitador * por #"
    ["ds*"]="Eliminar delimitador *"
    ["s"]="Saltar hacia adelante (fuzzy)"
    ["S"]="Saltar hacia atrás (fuzzy)"
    ["K"]="Hover info"
    ["gd"]="Ir a definición"
    ["gD"]="Ir a declaración"
    ["gi"]="Ir a implementación"
    ["gr"]="Listar referencias"

    ["<leader>lw"]="Typst Toggle auto-watch Typst"
    ["<leader>lv"]="Typst Abrir PDF en viewer"
    [":QuartoPreview"]="Quarto Vista previa HTML"
    [":QuartoRender"]="Quarto Render a .html/.pdf"

    ["<leader>r"]="Evaluar operador Magma"
    ["<leader>rr"]="Evaluar línea"
    ["<leader>ro"]="Mostrar salida"
    ["<leader>rd"]="Eliminar celda"
    ["<leader>rc"]="Reevaluar celda"

    ["<leader>ll"]="Compilar"
    ["<leader>lv"]="Abrir visor PDF"
    [":VimtexCompile"]="Compilar"
    [":VimtexView"]="Ver PDF"

    ["<leader>gs"]="Toggle gitsigns"
    ["<leader>gg"]="Mostrar blame"
    ["<leader>gl"]="Mostrar el blame de linea"
)

# Build list for dmenu: "KEY  →  #DESCRIPTION#"
Choices=""
for Key in "${!ScriptMap[@]}"; do
    Choices+="$Key  ==>  ${ScriptMap[$Key]}\n"
done

Choice=$(printf "%b" "$Choices" | dmenu -c -l 50 -i -p "Nvim Shortcuts")
exit 0









