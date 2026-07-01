#!/bin/bash

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Sun 29. Mar 2026
#
# Purpose:      Takes a recording of a region of the screen.
# =============================================================================

wf-recorder -g "$(slurp)" -f screen.mp4
