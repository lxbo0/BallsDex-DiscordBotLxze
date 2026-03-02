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
    DJANGO_SETTINGS_MODULE=admin_panel.settings

# Pillow / image processing dependencies
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community libraqm-dev && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main postgresql18-client && \
    apk add --no-cache tiff-dev jpeg-dev openjpeg-dev zlib-dev freetype-dev \
    lcms2-dev libwebp-dev tcl-dev tk-dev harfbuzz-dev fribidi-dev \
    libimagequant-dev libxcb-dev libpng-dev libavif-dev git build-base
    
# System dependencies
RUN apk add --no-cache tiff-dev jpeg-dev zlib-dev freetype-dev \
    lcms2-dev libwebp-dev tcl-dev tk-dev harfbuzz-dev fribidi-dev \
    libimagequant-dev libxcb-dev libpng-dev libavif-dev git build-base postgresql18-client

# Create ballsdex user
ARG UID GID
RUN addgroup -S ballsdex -g ${GID:-1000} && adduser -S ballsdex -G ballsdex -u ${UID:-1000}

# Copy all repo
COPY . /code

# Set working directory to repo root to install dependencies
WORKDIR /code

# Install Python dependencies system-wide
RUN pip install --upgrade pip && pip install -r requirements.txt

# Make Python see ballsdex module
ENV PYTHONPATH=/code:$PYTHONPATH

# Switch to admin_panel for runtime
WORKDIR /code/admin_panel

# Run as ballsdex user
USER ballsdex

# Start the bot
CMD ["python3", "-m", "ballsdex"]

