#!/usr/bin/env python3

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Thu 30. Apr 2026
#
# Purpose:      Matplotlib style wrapper
# =============================================================================
# ~/Tools/matplotlib/style.py

import matplotlib.pyplot as plt
import scienceplots


def apply_style():
    plt.style.use(["science", "grid"])
    plt.rcParams.update(
        {
            "font.size": 10,
            "axes.labelsize": 10,
            "axes.titlesize": 11,
            "legend.fontsize": 9,
            "figure.dpi": 150,
            "savefig.dpi": 300,
        }
    )
