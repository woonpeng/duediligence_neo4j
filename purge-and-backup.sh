#!/bin/bash
set -euo pipefail

mkdir -p /data/backups && \
service neo4j stop && \
  pushd /data/backups && \
    max=4 && \
    /var/lib/neo4j/bin/neo4j-admin dump --database=graph.db --to=graph.db.dump.tmp && \
    (for (( i=$max-2; i>=0; i-- )); do
    if [ -f graph.db.dump.$i ]; then mv graph.db.dump.$i graph.db.dump.$((i+1)); fi done && \
    if [ -f graph.db.dump ]; then mv graph.db.dump graph.db.dump.0; fi && \
    if [ -f graph.db.dump.tmp ]; then mv graph.db.dump.tmp graph.db.dump; fi) && popd && \
  pushd /data/databases && \
    rm -rf graph.db && popd && service neo4j start

source bin/wait-for-db.sh
