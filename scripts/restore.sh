#!/bin/bash
set -euo pipefail

BACKUP_FILENAME=""

mkdir -p /data/backups && \
service neo4j stop && \
  pushd /data/backups && \
    if [ $# -eq 0 ] || [ -z "$1" ] ; then \
      BACKUP_FILENAME=$(ls -rc | tail -n 1)
      printf "Restoring latest backup from $BACKUP_FILENAME\n"
    else \
      RAW=$1
      BACKUP_FILENAME="${RAW//\//_}".dump
      printf "Restoring backup from $BACKUP_FILENAME\n"
    fi && \
    neo4j-admin load --database=graph.db --from="$BACKUP_FILENAME" --force=true && \
  popd
service neo4j start

source /opt/neo4j-webhook/wait-for-db.sh
