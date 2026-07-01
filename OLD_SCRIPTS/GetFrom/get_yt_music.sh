#!/bin/bash

notify-send "Download Starting"

# Obtener URL del portapapeles (Wayland o X11)
if [[ "$XDG_SESSION_TYPE" == "wayland" ]] && command -v wl-paste &>/dev/null; then
    youtube_url=$(wl-paste --no-newline)
elif command -v xclip &>/dev/null; then
    youtube_url=$(xclip -o -selection clipboard 2>/dev/null)
else
    notify-send "Clipboard tool not found"
    exit 1
fi

if [[ -z "$youtube_url" ]]; then
    notify-send "No URL found in clipboard"
    exit 1
fi

# Ejecutar yt-dlp desde PATH
if ! command -v yt-dlp >/dev/null; then
    notify-send "yt-dlp not installed"
    exit 1
fi

yt-dlp \
    --extract-audio \
    --audio-format mp3 \
    --audio-quality 0 \
    --embed-thumbnail \
    --add-metadata \
    --no-playlist \
    --output "$HOME/Music/%(title)s.%(ext)s" \
    "$youtube_url"

notify-send "Download Complete"

mpc update

