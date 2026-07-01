#!/bin/bash

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Sun 29. Mar 2026
#
# Purpose:      Unify the capture functionality of both screen and camera.
# =============================================================================

#!/bin/bash

case "$1" in
  photo)
    ffmpeg -f v4l2 -i /dev/video0 -frames:v 1 "$HOME/Pictures/photo_$(date +%s).jpg"
    ;;
  video)
    ffmpeg -f v4l2 -i /dev/video0 "$HOME/Videos/webcam_$(date +%s).mp4"
    ;;
  screen)
    wf-recorder -f "$HOME/Videos/screen_$(date +%s).mp4"
    ;;
  region)
    wf-recorder -g "$(slurp)" -f "$HOME/Videos/region_$(date +%s).mp4"
    ;;
  *)
    echo "Uso: capture {photo|video|screen|region}"
    ;;
esac
