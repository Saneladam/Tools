#!/bin/bash

# Este script descarga un video de YouTube como audio,
# añade metadatos y arte de álbum, y actualiza la base de datos de MPD.

# Verifica si se proporcionó una URL.
if [ -z "$1" ]; then
    echo "Use: $0 <URL_de_YouTube>"
    exit 1
fi

URL="$1"
MUSIC_DIR="$HOME/Music"

# 1. Descarga el audio con metadatos y arte de álbum
echo "Downloading audio from URL: $URL"
yt-dlp \
  --extract-audio \
  --audio-format mp3 \
  --audio-quality 0 \
  --embed-thumbnail \
  --add-metadata \
  --output "$MUSIC_DIR/%(artist)s - %(title)s.%(ext)s" \
  "$URL"

if [ $? -ne 0 ]; then
    echo "Error: Download failed yt-dlp."
    exit 1
fi

# 2. Actualiza la base de datos de MPD
echo "Updating database to MPD..."
mpc update

echo "¡Process Completed! Song added to the database and MPD."
