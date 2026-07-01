#!/usr/bin/env bash

# ---- Dependencies ----
if ! command -v yt-dlp &>/dev/null || ! command -v notify-send &>/dev/null || ! command -v mpc &>/dev/null; then
    notify-send "Dependency Error" "Please ensure 'yt-dlp', 'libnotify' and 'mpc' are installed."
    exit 1
fi

MUSIC_BASE_DIR="$HOME/Music"
DOWNLOAD_TYPE=""

# ---- Parse flags ----
while getopts ":t:" opt; do
    case "$opt" in
        t)
            case "$OPTARG" in
                s|song) DOWNLOAD_TYPE="Song" ;;
                p|playlist) DOWNLOAD_TYPE="Playlist" ;;
                *)
                    notify-send "Invalid option" "Use -t s (song) or -t p (playlist)"
                    exit 1
                    ;;
            esac
            ;;
        *)
            notify-send "Usage error" "Usage: $0 -t [s|p]"
            exit 1
            ;;
    esac
done

if [[ -z "$DOWNLOAD_TYPE" ]]; then
    notify-send "Missing option" "You must specify -t s (song) or -t p (playlist)"
    exit 1
fi

# ---- Clipboard URL ----
get_url_from_clipboard() {
    local url=""
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]] && command -v wl-paste &>/dev/null; then
        url=$(wl-paste --no-newline)
    elif command -v xclip &>/dev/null; then
        url=$(xclip -o -selection clipboard 2>/dev/null)
    fi

    if [[ "$url" =~ ^https?://(www\.youtube\.com|youtu\.be)/.+ ]]; then
        echo "$url"
    else
        notify-send "Clipboard Error" "No valid YouTube URL found."
        exit 1
    fi
}

# ---- Download ----
download_and_update() {
    local selection="$1"
    local url="$2"

    local target_dir="$MUSIC_BASE_DIR"
    local playlist_option="--no-playlist"

    if [[ "$selection" == "Playlist" ]]; then
        target_dir="$MUSIC_BASE_DIR/Playlist"
        mkdir -p "$target_dir"
        playlist_option=""
    fi

    notify-send "yt-dlp" "Downloading $selection..."

    yt-dlp \
        --extract-audio \
        --audio-format mp3 \
        --audio-quality 0 \
        --embed-thumbnail \
        --parse-metadata "artist:%(artist)s" \
        --embed-metadata \
        --write-subs \
        --write-auto-subs \
        --sub-lang en,es \
        --convert-subs lrc \
        --restrict-filenames \
        $playlist_option \
        --output "$target_dir/%(artist)s - %(title)s.%(ext)s" \
        "$url" || {
            notify-send -u critical "Download Error" "yt-dlp failed."
            exit 1
        }

    notify-send "MPD" "Updating database..."
    mpc update

    notify-send "Done" "$selection added to your music library 🎵"
}

# ---- Main ----
URL=$(get_url_from_clipboard)
download_and_update "$DOWNLOAD_TYPE" "$URL"
