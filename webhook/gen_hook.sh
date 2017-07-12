#!/usr/bin/env bash
set -euo pipefail

# Replace the hook configuration with the secret key
sed -i -e "s#\"secret\": \"\"#\"secret\": \"$WEBHOOK_SECRET\"#" $1
