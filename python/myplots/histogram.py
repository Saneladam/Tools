#!/usr/bin/env python3

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Wed 10. Jun 2026
#
# Purpose:      Generates a histogram
# =============================================================================

from myplots.myplot import _finalize, _base_fig


def histogram(data, bins=30, title=None, output=None, show=False):
    fig, ax = _base_fig()

    ax.hist(
        data,
        bins=bins,
        alpha=0.85,
        edgecolor="black",
    )

    ax.set_xlabel("Value")
    ax.set_ylabel("Frequency")

    _finalize(fig, ax, title, output, show)
