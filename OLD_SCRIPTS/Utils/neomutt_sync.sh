#!/bin/bash
# =============================================================================
# Authors:      Roman Garcia Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Fri 19. Dec 2025
#
# Purpose:      runs the nemutt and also syncs the mail in bg 
# =============================================================================

mbsync -a &
exec neomutt "@"
