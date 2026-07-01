#!/bin/bash

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Fri 30. Jan 2026
#
# Purpose:      Give autostart perms to enable X 
# =============================================================================

sudo chown root:root /tmp/.X11-unix
sudo chmod 1777 /tmp/.X11-unix
