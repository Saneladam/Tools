#!/bin/bash

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Thu 20. Aug 2026
#
# Purpose:      Captures terminal activity. 
# =============================================================================

FILENAME=$(date +%m_%d_%Y_%H:%M:%S).log
LOGDIR="$HOME/Logs/terminal"

mkdir -p $LOGDIR

script -q -f "$LOGDIR/$FILENAME"
