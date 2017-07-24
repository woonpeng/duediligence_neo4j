#!/usr/bin/env bash
set -euo pipefail
/opt/neo4j-webhook/webhook -hooks /etc/opt/neo4j-webhook/hooks.json -verbose

