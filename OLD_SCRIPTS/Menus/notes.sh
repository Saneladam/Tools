#!/usr/bin/bash
TERMINAL="kitty"
folder=$HOME/Notes/

# newnote () { \
#   name="$(echo "" | dmenu -p "Enter a notename: " <&-)" || exit 0
#   : "${name:=$(date +%F-%a | tr ':' '-')}"
#   setsid -f "$TERMINAL" -e nvim $folder$name".md" >/dev/null 2>&1
# }
newnote () {
    name="$(wmenu -p 'Enter a notename:')" || return 0
    : "${name:=$(date +%F-%a | tr ':' '-')}"
    setsid -f "$TERMINAL" -e nvim "$folder/$name.md" >/dev/null 2>&1
}

selected () { \
  choice=$(echo -e "New\n$(command ls -t1 $folder | sort -r)" | dmenu -c -nb '#ffffff' -nf '#000000' -sb '#0000ff' -sf '#ffffff' -l 25 -i -p "Choose note or create new: ")
  case $choice in
    New) newnote ;;
    *.md) setsid -f "$TERMINAL" -e nvim "$folder$choice" >/dev/null 2>&1 ;;
    *) exit ;;
  esac
}

selected
