#!/bin/bash

CurrentSong=$(mpc current -f "%file%")
CurrentTitle=$(mpc current -f "%title%")
PlaylistsDir="/home/madas/Music/Playlist"
SongPath="/home/madas/Music/$CurrentSong"

# Elegir playlist con dmenu (quitando extensión .m3u)
PLAYLIST=$(ls "$PlaylistsDir" | sed 's/\.m3u$//' | dmenu -c -l 50 -i -p "Choose a Playlist for $CurrentTitle")

# Salir si no se seleccionó nada
[[ -z "$PLAYLIST" ]] && exit 1

# Ruta completa de la playlist
Playlist="$PlaylistsDir/$PLAYLIST.m3u"

# Añadir canción o crear playlist
if [[ -f "$Playlist" ]]; then
    if grep -Fxq "$SongPath" "$Playlist"; then
        notify-send "$CurrentTitle" "Already in $PLAYLIST"
    else
        echo "$SongPath" >> "$Playlist"
        notify-send "$CurrentTitle" "Added to $PLAYLIST"
    fi
else
    echo "#EXTM3U" > "$Playlist"
    echo "$SongPath" >> "$Playlist"
    notify-send "$PLAYLIST" "Created and added $CurrentTitle"
fi

mpc update >/dev/null 2>&1
