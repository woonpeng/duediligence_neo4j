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

# Wait for neo4j to start by trying to connect to the neo4j address and port
# The official neo4j image starts neo4j once to check for correct credentials
# stops it, and then starts it for real.
NEO4J_TIMEOUT=60
DATABASE_DEV="/dev/tcp/localhost/7687"
echo "Checking database connection ${DATABASE_DEV}"
timeout -t ${NEO4J_TIMEOUT} bash <<EOT

neo4j_wait() {
  while ! (echo > "${DATABASE_DEV}") >/dev/null 2>&1; do
      echo "Waiting for database ${DATABASE_DEV}"
      sleep 2;
  done;

  sleep 5
}

neo4j_wait
neo4j_wait
EOT
RESULT=$?

if [ ${RESULT} -eq 0 ]; then
    echo "Neo4J database now available"
else
    echo "Neo4J database is not available"
    exit 1
fi
