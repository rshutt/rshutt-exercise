# syntax=docker/dockerfile:1

FROM python:3.13-slim AS runtime

ARG VERSION=0.0.0
ENV SETUPTOOLS_SCM_PRETEND_VERSION_FOR_AUTOMATER_WS=$VERSION

ENV PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1 \
  PIP_DISABLE_PIP_VERSION_CHECK=1 \
  PIP_NO_CACHE_DIR=1

WORKDIR /app

# System deps (add build-essential only if you compile wheels)
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Copy only metadata first for better layer caching
COPY pyproject.toml README.md ./

# Now copy the actual source
COPY src ./src

# Install your package (and deps) from pyproject
# If you want dev tools inside the image, use .[dev]
RUN python -m pip install --upgrade pip \
  && python -m pip install .

# Re-install in case code changed after cached layer (fast for pure python)
RUN python -m pip install .

EXPOSE 8000

# Uvicorn is fine to start; scale with --workers or switch to gunicorn later
CMD ["python", "-m", "uvicorn", "automater_ws.main:app", "--host", "0.0.0.0", "--port", "8000"]
