#!/bin/bash
set -euo pipefail

mkdir -p /data/backups && \
service neo4j stop && \
  pushd /data/backups && \
  if [ $# -eq 0 ] || [ $1 -eq 0 ] ; then \
    if [ -f graph.db.dump ]; then /var/lib/neo4j/bin/neo4j-admin load --database=graph.db --from=graph.db.dump --force=true ; fi; \
  else \
    i=$1
    if [ -f graph.db.dump.$((i-1)) ]; then /var/lib/neo4j/bin/neo4j-admin load --database=graph.db --from=graph.db.dump.$((i-1)) --force=true ; fi; \
  fi && \
  popd && service neo4j start

source bin/wait-for-db.sh
