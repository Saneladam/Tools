#!/bin/bash

# =============================================================================
# Authors:      Roman Garcia Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Tue 25. Nov 2025
#
# Purpose:      Execute conky in the background 
# =============================================================================

if pgrep -x conky >/dev/null; then
    exit
else
    conky &
fi

