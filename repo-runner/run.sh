#!/bin/bash

set -euo pipefail

REG_TOKEN=$(curl -sX POST \
    -H "Authorization: token ${ACCESS_TOKEN}" \
    "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runners/registration-token" \
    | jq .token --raw-output)

cd /home/docker/actions-runner || exit 1

./config.sh --url "https://github.com/${REPO_OWNER}/${REPO_NAME}" --token "${REG_TOKEN}" --unattended --disableupdate

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token "${REG_TOKEN}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
