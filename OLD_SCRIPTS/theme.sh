#!/bin/bash

# This script sets the theme for various applications based on the argument passed.
# Usage: ./theme.sh [dark|light]

wallpaper() {
    if [ "$1" = "light" ]; then
        desktop="$HOME/Pictures/Wallpaper/atom.svg"
    elif [ "$1" = "dark" ]; then
        desktop="$HOME/Pictures/Wallpaper/darkatom.svg"
    fi

    cp "$desktop" "$HOME/Pictures/Wallpaper/CURRENT"
    pkill swaybg
    swaybg -i "$HOME/Pictures/Wallpaper/CURRENT" -m fill >/dev/null 2>&1 &
    echo "  - swaybg changed"
}
terminal() {
    if [ "$1" = "light" ]; then
        kittytheme="$HOME/.config/kitty/light-theme.conf"
    elif [ "$1" = "dark" ]; then
        kittytheme="$HOME/.config/kitty/dark-theme.conf"
    else
        echo "  - kitty: invalid theme"
        return 1
    fi

    cp "$kittytheme" "$HOME/.config/kitty/current-theme.conf"
    for pid in $(pgrep kitty); do
        kill -SIGUSR1 $pid 2>/dev/null
    done
    echo "  - kitty changed"
}
neovim() {
    if [ "$1" = "light" ]; then
        target="light"
        sed -i 's/^colorscheme zaibatsu/colorscheme vim/' "$HOME/.config/nvim/init.vim"
    elif [ "$1" = "dark" ]; then
        target="dark"
        sed -i 's/^colorscheme vim/colorscheme zaibatsu/' "$HOME/.config/nvim/init.vim"
    else
        echo "  - nvim: invalid theme"
        return 1
    fi

    # Cambiar línea aunque tenga espacios
    sed -i "s/^set background=.*/set background=$target/" \
        "$HOME/.config/nvim/init.vim"

    for server in $(nvim --serverlist 2>/dev/null); do
        nvim --server "$server" --remote-send ":set background=$1<CR>"
    done

    echo "  - nvim changed"
}

waybar_style() {
    if [ "$1" = "light" ]; then
        target_fg="#000000"
        target_bg="#ffffff"
    elif [ "$1" = "dark" ]; then
        target_fg="#ffffff"
        target_bg="#000000"
    else
        echo "  - waybar: invalid theme"
        return 1
    fi

    # Cambiar línea
    sed -i "s/^\s*@define-color foreground\s*.*;/@define-color foreground ${target_fg};/" "$HOME/.config/waybar/style.css"
    sed -i "s/^\s*@define-color background\s*.*;/@define-color background ${target_bg};/" "$HOME/.config/waybar/style.css"

    pkill waybar
    waybar >/dev/null 2>&1 &

    echo "  - waybar changed"
}

conky_style() {
    if [ "$1" = "light" ]; then
        from_color="white"
        to_color="red"
    elif [ "$1" = "dark" ]; then
        from_color="red"
        to_color="white"
    else
        echo "  - conky: invalid theme"
        return 1
    fi

    # Cambiar línea
    sed -i "s/${from_color}/${to_color}/" "$HOME/.conkyrc" 2>/dev/null

    pkill conky
    conky >/dev/null 2>&1 &
    echo "  - conky changed"
}

case "$1" in
    light|dark)
        echo "Setting $1 theme..."
        wallpaper "$1"
        terminal "$1"
        neovim "$1"
        waybar_style "$1"
        conky_style "$1"
        echo "$1 theme set successfully."
        ;;
    *)
        echo "Select a valid theme: 'dark' or 'light'."
        exit 1
        ;;
esac
