#!/usr/bin/env bash

notify-send "Download Starting"

# --------
# Parse flags
# --------
DOWNLOAD_TYPE="song"

while getopts ":t:" opt; do
  case "$opt" in
    t)
      case "$OPTARG" in
        s|song) DOWNLOAD_TYPE="song" ;;
        p|playlist) DOWNLOAD_TYPE="playlist" ;;
        *)
          notify-send "Invalid option" "Use -t s (song) or -t p (playlist)"
          exit 1
          ;;
      esac
      ;;
    *)
      notify-send "Usage" "Usage: $0 -t [s|p]"
      exit 1
      ;;
  esac
done

# --------
# Clipboard URL
# --------
if [[ "$XDG_SESSION_TYPE" == "wayland" ]] && command -v wl-paste &>/dev/null; then
  youtube_url=$(wl-paste --no-newline)
elif command -v xclip &>/dev/null; then
  youtube_url=$(xclip -o -selection clipboard 2>/dev/null)
else
  notify-send "Clipboard tool not found"
  exit 1
fi

[[ -z "$youtube_url" ]] && notify-send "No URL found in clipboard" && exit 1

command -v yt-dlp >/dev/null || { notify-send "yt-dlp not installed"; exit 1; }

# --------
# yt-dlp options
# --------
YTDLP_OPTS=(
  --extract-audio
  --audio-format mp3
  --audio-quality 0
  --embed-thumbnail
  --add-metadata
)

if [[ "$DOWNLOAD_TYPE" == "song" ]]; then
  YTDLP_OPTS+=(--no-playlist)
  TARGET_DIR="$HOME/Music"
else
  TARGET_DIR="$HOME/Music/Playlist"
  mkdir -p "$TARGET_DIR"
fi

# --------
# Download
# --------
yt-dlp \
  "${YTDLP_OPTS[@]}" \
  --output "$TARGET_DIR/%(title)s.%(ext)s" \
  "$youtube_url" || exit 1

# --------
# Update MPD
# --------
mpc update
notify-send "Download Complete "
