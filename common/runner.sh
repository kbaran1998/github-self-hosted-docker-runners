#!/bin/bash
# Shared runner lifecycle — configure, trap cleanup, and start.
# Callers must set RUNNER_URL and REG_TOKEN before sourcing this file.

set -euo pipefail

cd /home/docker/actions-runner || exit 1

./config.sh --url "${RUNNER_URL}" --token "${REG_TOKEN}" --unattended --disableupdate

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token "${REG_TOKEN}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
