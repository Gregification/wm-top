#!/bin/bash

# 1. updates the yocto machine config to use the same CubeMX project the docker container was built for
# 2. starts icecream if its enabled

set -e

# Default environment variables if not supplied
BOARD_NAME="${BOARD_NAME:-ref-157d-dk1}"
USER="${USER:-dev}"
ICECREAM_yippie="${ICECREAM_yippie:-false}"

if [ "$ICECREAM_yippie" = "true" ]; then
    echo "Starting iceccd service..."
    sudo service iceccd start || echo "Failed to start iceccd service."
fi


# exit
if [ "$#" -eq 0 ] || [ "$1" = "bash" ]; then
    # Keep container alive if running detached without TTY
    exec tail -f /dev/null
else
    exec "$@"
fi

