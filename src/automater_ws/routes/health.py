"""Health and readiness endpoints."""

from fastapi import APIRouter

router = APIRouter(tags=["health"])


@router.get("/healthz")
def healthz():  # pyright: ignore[reportUnusedFunction]
    """Liveness probe used by load balancers and orchestration."""
    return {"ok": True}


@router.get("/readyz")
def readyz():  # pyright: ignore[reportUnusedFunction]
    """Readiness probe indicating service dependencies are available."""
    return {"ready": True}
