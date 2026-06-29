#!/bin/bash

set -euo pipefail

# shellcheck disable=SC2034
REG_TOKEN=$(curl -sX POST \
    -H "Authorization: token ${ACCESS_TOKEN}" \
    "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runners/registration-token" \
    | jq .token --raw-output)

# shellcheck disable=SC2034
RUNNER_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}"

# shellcheck source=../common/runner.sh
source /common/runner.sh
