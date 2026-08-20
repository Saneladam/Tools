#!/bin/bash

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Wed 24. Jun 2026
#
# Purpose:      Configures the swaylock 
# =============================================================================

grim - | magick - -resize 25% -blur 0x10 "/tmp/lockscreen.png"

# --ring-color 7aa2f7 \
# --key-hl-color bb9af7 \
# --inside-color 1a1b26cc \
# --text-color c0caf5
# --bs-hl-color f7768e \
exec swaylock \
    --daemonize \
    --image /tmp/lockscreen.png \
    --scaling fill \
    \
    --indicator-radius 90 \
    --indicator-thickness 6 \
    \
    --inside-color    000000cc \
    --ring-color      9f7aea \
    --key-hl-color    c4a1ff \
    --bs-hl-color     d84a5a \
    --text-color      ffffff \

