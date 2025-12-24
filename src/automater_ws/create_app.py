"""Application factory for the Automater Web App."""

from fastapi import FastAPI

from automater_ws.routes.health import router as health_router
from automater_ws.version import __version__


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(
        title="Automater Web App",
        version=__version__,
    )

    app.include_router(health_router)

    return app
