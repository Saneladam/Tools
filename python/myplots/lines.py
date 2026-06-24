#!/usr/bin/env python3

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Wed 10. Jun 2026
#
# Purpose:
# =============================================================================

from myplots.myplot import _finalize, _base_fig
import numpy as np


def multi_line(
    x,
    ys: dict,
    title=None,
    output=None,
    show=False,
    cmap="coolwarm",
):
    """
    ys: {"curve1": y1, "curve2": y2}
    """

    fig, ax = _base_fig()

    n = len(ys)
    colors = plt.get_cmap(cmap)(np.linspace(0, 1, n))

    for (label, y), c in zip(ys.items(), colors):
        ax.plot(
            x,
            y,
            label=label,
            color=c,
            marker="o",
            markersize=3,
            linewidth=1.8,
        )

    ax.legend()
    ax.set_xlabel("x")
    ax.set_ylabel("y")

    _finalize(fig, ax, title, output, show)
