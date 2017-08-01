#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

set -x

docker build --pull -t neo4j-webhook -f Dockerfile.packaging .

rm -f SHA256SUMS*
docker run --rm neo4j-webhook sh -c 'cd /root/rpmbuild/ && tar -c RPMS' | tar -xv
find RPMS/ -type f ! -iname "SHA256SUMS" -exec sha256sum "{}" + > SHA256SUMS

echo RPM packages created in 'RPMS' folder:
ls -R RPMS/
