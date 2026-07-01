#!/bin/bash

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Sun 29. Mar 2026
#
# Purpose:      Take a picture with the camara.
# =============================================================================

ffmpeg -f v4l2 -i /dev/video0 -frames:v 1 foto.jpg
