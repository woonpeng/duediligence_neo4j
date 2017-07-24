#!/bin/bash
set -euo pipefail

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
