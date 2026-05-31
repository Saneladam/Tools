#!/usr/bin/env python3

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Thu 28. May 2026
#
# Purpose:      Font preview
# =============================================================================

import subprocess
import matplotlib.pyplot as plt

fonts = subprocess.check_output(["fc-list", ":family"]).decode().splitlines()
fonts = sorted(set(f.split(",")[0] for f in fonts))

sample = "The quick brown fox jumps over the lazy dog 1234567890"

for f in fonts[:30]:  # limita preview
    plt.figure()
    plt.title(f)
    plt.text(0.1, 0.5, sample, fontname=f, fontsize=14)
    plt.axis("off")

plt.show()
