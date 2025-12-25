"""Application factory for the Automater Web App."""

from __future__ import annotations

import logging
import os
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from automater_ws.routes.health import router as health_router
from automater_ws.routes.root import router as root_router
from automater_ws.version import get_version

log = logging.getLogger("automater_ws")


@asynccontextmanager
async def app_lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Application lifespan handler."""
    instance = os.getenv("HOSTNAME", "unknown")
    version = get_version()

    log.info(
        "starting automater_ws (instance=%s, version=%s)",
        instance,
        version,
    )

    # ---- startup complete ----
    yield
    # ---- shutdown begins ----

    log.info("stopping automater_ws (instance=%s)", instance)


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(
        title="Automater Web App",
        lifespan=app_lifespan,
    )

    app.include_router(health_router)
    app.include_router(root_router)

    return app
