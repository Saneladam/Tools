#!/bin/bash

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Sun 29. Mar 2026
#
# Purpose:      Takes video with audio.
# =============================================================================

ffmpeg -f v4l2 -i /dev/video0 -f pulse -i default video.mp4
