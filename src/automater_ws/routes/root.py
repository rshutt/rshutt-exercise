"""Health and readiness endpoints."""

from __future__ import annotations

import time

from fastapi import APIRouter

router = APIRouter(tags=["root"])


@router.get("/")
def root() -> dict[str, object]:  # pyright: ignore[reportUnusedFunction]
    """Core business logic"""

    return {
        "message": "Automate all the things!",
        "timestamp": int(time.time()),
    }
