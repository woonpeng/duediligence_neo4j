FROM neo4j:3.1.3

# Install findutils os package; used for housekeeping db backups
RUN set -ex \
      && apk add --update findutils

# Install web hook and setup start up script to use webhook and run neo4j
RUN set -ex \
  && curl -L https://github.com/adnanh/webhook/releases/download/2.6.4/webhook-linux-386.tar.gz \
       | tar xz -C bin --strip-components 1 \
  && sed -i -e "s#exec bin/neo4j console#bin/service neo4j start \n bin/gen_hook.sh conf/hooks.json \n webhook -hooks conf/hooks.json#" /docker-entrypoint.sh

# Copy hooks configuration 
COPY webhook/hooks.json conf/

# Copy the script and dummy 'service' command to emulate as neo4j service 
# This is to make the setup similar to an actual neo4j server (at least to the scripts)
COPY scripts/ webhook/gen_hook.sh webhook/service bin/

# Add path to the bin directory
ENV PATH=${PATH}:/var/lib/neo4j/bin

# Setup a default secret key needed by webhook
ENV WEBHOOK_SECRET=fixme
