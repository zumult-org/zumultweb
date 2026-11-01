#!/bin/sh
set -e

# Adapt the public ZuMult URLs to the deployment environment.
# Example: PUBLIC_BASE_URL=https://zumult.kuwi.tu-dortmund.de
if [ -n "${PUBLIC_BASE_URL:-}" ]; then
    sed -i \
        "s@http://localhost:8080@${PUBLIC_BASE_URL}@g" \
        "${ZUMULT_CONFIG_PATH}"

    echo "[entrypoint] base URLs rewritten to ${PUBLIC_BASE_URL}"
fi

# Start Tomcat, replacing this shell process.
exec "$@"