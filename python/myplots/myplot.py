#!/usr/bin/env python3

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Wed 10. Jun 2026
#
# Purpose:      Plots with general arguments
# =============================================================================

import matplotlib.pyplot as plt


def _base_fig():
    fig, ax = plt.subplots()
    return fig, ax


def _finalize(fig, ax, title=None, output=None, show=False):
    if title:
        ax.set_title(title)

    if output:
        fig.savefig(output, bbox_inches="tight", dpi=300)

    if show:
        plt.show()
    else:
        plt.close(fig)
