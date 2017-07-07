#!/usr/bin/env bash
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


DB_TIMEOUT=180
set +e
# Wait for Neo4J to be available
# Strategy from http://superuser.com/a/806331/98716
echo "Checking database connection"
DATABASE_DEV="/dev/tcp/localhost/7687"

timeout ${DB_TIMEOUT} bash <<EOT
while ! (echo > "${DATABASE_DEV}") >/dev/null 2>&1; do
    echo "Waiting for database ${DATABASE_DEV}"
    sleep 2;
done;
EOT
RESULT=$?

if [ ${RESULT} -eq 0 ]; then
    echo "Neo4j database available"
else
    echo "Neo4j database is not available"
    exit 1
fi
set -e
