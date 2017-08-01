#!/bin/bash
set -euo pipefail

MAX_DAYS=30

printf "Cleanup backup files older than $MAX_DAYS days\n"
find {{WEBHOOK_BACKUP_PATH}} -name '*.dump' -type f -mtime "$MAX_DAYS" -delete
