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
    plt.style.use(["science", "grid", "no-latex"])
    plt.rcParams.update(
        {
            "font.family": "serif",
            "font.serif": ["DejaVu Serif"],
            "mathtext.fontset": "cm",
            "text.usetex": False,
            "font.size": 10,
            "axes.labelsize": 10,
            "axes.titlesize": 11,
            "legend.fontsize": 9,
            "xtick.labelsize": 9,
            "ytick.labelsize": 9,
            "figure.dpi": 150,
            "savefig.dpi": 300,
            "figure.constrained_layout.use": True,
            "grid.alpha": 0.3,
            "lines.linewidth": 1.8,
            "savefig.bbox": "tight",
        }
    )
