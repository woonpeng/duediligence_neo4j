#!/bin/bash
set -euo pipefail

MAX_DAYS=30

find /data/backups -name '*.dump' -type f -mtime "$MAX_DAYS" -delete
