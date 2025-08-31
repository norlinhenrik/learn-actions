# syntax=docker/dockerfile:1.4

FROM ghcr.io/acsone/odoo-bedrock:18.0-py312-noble-latest

# Install apt runtime dependencies.
RUN set -e \
  && apt update \
  && apt -y install --no-install-recommends \
       postgresql-client \
       git \
       python3.12-dev \
       build-essential \
       libpq-dev \
       libldap2-dev \
       libsasl2-dev \
  && apt -y clean \
  && rm -rf /var/lib/apt/lists/*

# Install uv, and configure it for optimal usage in Dockerfile.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
ENV UV_PROJECT_ENVIRONMENT=$VIRTUAL_ENV
ENV UV_LINK_MODE=copy
ENV UV_COMPILE_BYTECODE=1

# Install the app
COPY . /app
WORKDIR /app
RUN python -m compileall .
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync
