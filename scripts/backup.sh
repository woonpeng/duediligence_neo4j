#!/bin/bash
set -euo pipefail

BACKUP_FILENAME=""

mkdir -p {{WEBHOOK_BACKUP_PATH}} && \
sudo service neo4j stop && \
  queryresult=$(neo4j-admin check-consistency | grep "record format from store") && \
  regex='record format from store (.*)' && \
  [[ $queryresult =~ $regex ]] && \
  dbaddress=${BASH_REMATCH[1]} && \
  graphname=$(basename $dbaddress) && \
  pushd {{WEBHOOK_BACKUP_PATH}} && \
    if [ $# -eq 0 ] || [ -z "$1" ] ; then \
      BACKUP_FILENAME=$(date -I).dump
    else \
      RAW=$1
      BACKUP_FILENAME="${RAW//\//_}".dump
    fi && \
    rm -f "$BACKUP_FILENAME" && \
    printf "Backing up database to $BACKUP_FILENAME\n" && \
    neo4j-admin dump --database=$graphname --to="$BACKUP_FILENAME" && \
  popd
sudo service neo4j start

source {{WEBHOOK_INSTALL_PATH}}/wait-for-db.sh
