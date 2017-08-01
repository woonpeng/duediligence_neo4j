#!/usr/bin/env bash
set -euo pipefail
if [ ${NEO4J_WEBHOOK_CERT:-} ] && [ ${NEO4J_WEBHOOK_KEY:-} ] && [ -f $NEO4J_WEBHOOK_CERT ] && [ -f $NEO4J_WEBHOOK_KEY ]; then
  {{WEBHOOK_INSTALL_PATH}}/webhook -hooks {{WEBHOOK_CONFIG_PATH}}/hooks.json -verbose -secure -cert $NEO4J_WEBHOOK_CERT -key $NEO4J_WEBHOOK_KEY
else
  {{WEBHOOK_INSTALL_PATH}}/webhook -hooks {{WEBHOOK_CONFIG_PATH}}/hooks.json -verbose
fi
