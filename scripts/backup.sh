#!/bin/bash
set -euo pipefail

BACKUP_FILENAME=""

mkdir -p /data/backups && \
service neo4j stop && \
  pushd /data/backups && \
    if [ $# -eq 0 ] || [ -z "$1" ] ; then \
      BACKUP_FILENAME=$(date -I).dump
    else \
      RAW=$1
      BACKUP_FILENAME="${RAW//\//_}".dump
    fi && \
    rm -f "$BACKUP_FILENAME" && \
    printf "Backing up database to $BACKUP_FILENAME\n" && \
    neo4j-admin dump --database=graph.db --to="$BACKUP_FILENAME" && \
  popd
service neo4j start

source /opt/neo4j-webhook/wait-for-db.sh
