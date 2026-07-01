#!/usr/bin/env python3

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Thu 12. Feb 2026
#
# Purpose:      Download videos from youtube
# =============================================================================

from pytube import YouTube
from sys import argv

link = argv[1]
yt = YouTube(link)

print("Title: ", yt.title )

# yd = yt.streams.get_highest_resolution()

# yd.download("~/Videos")
