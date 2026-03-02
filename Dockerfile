# syntax=docker/dockerfile:1.7-labs

# Base image
FROM python:3.14.0-alpine3.22 AS base

# Environment variables
ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONHASHSEED=random \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    BALLSDEX_LOG_DIR=/var/log/ballsdex \
    BALLSDEXBOT_EXTRA_TOML=/code/admin_panel/config/extra.toml \
    STATIC_ROOT=/var/www/ballsdex/static \
    DJANGO_SETTINGS_MODULE=admin_panel.settings \
    PYTHONPATH=/code:$PYTHONPATH

# System dependencies for Pillow, PostgreSQL, etc.
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community libraqm-dev && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main postgresql18-client && \
    apk add --no-cache tiff-dev jpeg-dev openjpeg-dev zlib-dev freetype-dev \
        lcms2-dev libwebp-dev tcl-dev tk-dev harfbuzz-dev fribidi-dev \
        libimagequant-dev libxcb-dev libpng-dev libavif-dev git build-base

# Create ballsdex user
ARG UID=1000
ARG GID=1000
RUN addgroup -S ballsdex -g ${GID} && adduser -S ballsdex -G ballsdex -u ${UID} && \
    mkdir -p ${BALLSDEX_LOG_DIR} && chown ballsdex:ballsdex ${BALLSDEX_LOG_DIR}

# Copy the full repo
COPY . /code

# Set working directory to repo root for pip install
WORKDIR /code

# Debug: list files to make sure requirements.txt exists
RUN ls -l

# Install Python dependencies system-wide
RUN pip install --upgrade pip && pip install -r requirements.txt

# Switch working directory to admin_panel for runtime
WORKDIR /code/admin_panel

# Run as ballsdex user
USER ballsdex

# Start the bot
CMD ["python3", "-m", "ballsdex"]
