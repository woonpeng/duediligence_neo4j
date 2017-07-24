#!/bin/bash
set -euo pipefail

service neo4j stop && \
  pushd /data/databases && \
    printf "Purging the database\n"
    rm -rf graph.db && \
  popd && \
service neo4j start

source bin/wait-for-db.sh
