FROM neo4j:3.1.3

# Install findutils os package; used for housekeeping db backups
RUN set -ex \
      && apk add --update findutils sudo python \
      && curl "https://bootstrap.pypa.io/get-pip.py" | python && pip install j2cli

# Arguments
ARG WEBHOOK_VERSION
ARG WEBHOOK_INSTALL_PATH
ARG WEBHOOK_CONFIG_PATH
ARG WEBHOOK_USER
ARG WEBHOOK_GROUP
ARG WEBHOOK_SERVICE
ARG WEBHOOK_BACKUP_PATH
ARG WEBHOOK_NEO4J_BOLT_PORT

# Set installation options that will be used to update the scripts
ENV WEBHOOK_VERSION ${WEBHOOK_VERSION:-2.6.4}
ENV WEBHOOK_INSTALL_PATH ${WEBHOOK_INSTALL_PATH:-"/opt/neo4j-webhook"}
ENV WEBHOOK_CONFIG_PATH ${WEBHOOK_CONFIG_PATH:-"/etc/opt/neo4j-webhook"}
ENV WEBHOOK_USER ${WEBHOOK_USER:-"neo4j"}
ENV WEBHOOK_GROUP ${WEBHOOK_GROUP:-"neo4j"}
ENV WEBHOOK_SERVICE ${WEBHOOK_SERVICE:-"neo4j-webhook"}
ENV WEBHOOK_BACKUP_PATH ${WEBHOOK_BACKUP_PATH:-"/data/backups"}
ENV WEBHOOK_NEO4J_BOLT_PORT ${WEBHOOK_NEO4J_BOLT_PORT:-"7687"}

# Install web hook and setup start up script to use webhook and run neo4j
RUN set -ex \
  && mkdir -p /opt/neo4j-webhook \
  && mkdir -p /etc/neo4j-webhook \
  && curl -L https://github.com/adnanh/webhook/releases/download/${WEBHOOK_VERSION}/webhook-linux-386.tar.gz \
       | tar xz -C ${WEBHOOK_INSTALL_PATH}/ --strip-components 1 \
  && sed -i -e "s#exec bin/neo4j console#/${WEBHOOK_INSTALL_PATH}/service neo4j start \n ${WEBHOOK_INSTALL_PATH}/gen_hook.sh ${WEBHOOK_CONFIG_PATH}/hooks.json \n ${WEBHOOK_INSTALL_PATH}/neo4j-webhook.sh #" /docker-entrypoint.sh

# Copy hooks configuration 
COPY webhook/hooks.json ${WEBHOOK_CONFIG_PATH}/

# Copy the script and dummy 'service' command to emulate as neo4j service 
# This is to make the setup similar to an actual neo4j server (at least to the scripts)
COPY scripts/ webhook/gen_hook.sh webhook/service webhook/neo4j-webhook.sh webhook/configure-neo4j-webhook.sh ${WEBHOOK_INSTALL_PATH}/

# Add path to the bin directory
ENV PATH=${PATH}:${WEBHOOK_INSTALL_PATH}:/var/lib/neo4j/bin

# Setup a default secret key needed by webhook
ENV WEBHOOK_SECRET=fixme

# Update the files with the environment variables
RUN ${WEBHOOK_INSTALL_PATH}/update_vars.sh ${WEBHOOK_INSTALL_PATH}'/*.sh' && \
    ${WEBHOOK_INSTALL_PATH}/update_vars.sh ${WEBHOOK_CONFIG_PATH}'/*.json'

