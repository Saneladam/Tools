#!/usr/bin/env python3

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Wed 10. Jun 2026
#
# Purpose:      Scatter plot
# =============================================================================

from myplots.myplot import _base_fig, _finalize


def scatter(x, y, title=None, output=None, show=False, cmap="coolwarm"):
    fig, ax = _base_fig()

    sc = ax.scatter(x, y, c=y, cmap=cmap, s=15)

    plt.colorbar(sc, ax=ax)

    ax.set_xlabel("x")
    ax.set_ylabel("y")

    _finalize(fig, ax, title, output, show)
