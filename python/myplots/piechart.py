#!/usr/bin/env python3

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Wed 10. Jun 2026
#
# Purpose:      Plot a piechart
# =============================================================================

from myplots.myplot import _finalize, _base_fig


def pie_chart(data: dict, title=None, output=None, show=False):
    """
    data: {"A": 10, "B": 20, ...}
    """

    fig, ax = _base_fig()

    labels = list(data.keys())
    values = list(data.values())

    ax.pie(
        values,
        labels=labels,
        autopct="%1.1f%%",
        startangle=90,
        normalize=True,
        textprops={"fontsize": 10},
    )

    ax.axis("equal")  # círculo perfecto

    _finalize(fig, ax, title, output, show)
