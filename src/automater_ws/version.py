"""
Version helpers.

We keep version resolution in one place so the app can display build metadata without
importing packaging internals everywhere.
"""

from __future__ import annotations

from importlib.metadata import PackageNotFoundError
from importlib.metadata import version as pkg_version

DIST_NAME = "automater_ws"


def get_version() -> str:
    """Return the installed distribution version for this package."""
    try:
        return pkg_version(DIST_NAME)
    except PackageNotFoundError:  # pragma: no cover
        return "0.0.0"


__version__ = get_version()
