"""ASGI entrypoint for the Automater Web App."""

from automater_ws.create_app import create_app

app = create_app()
