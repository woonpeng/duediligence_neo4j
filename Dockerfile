FROM neo4j:3.1.3

# Install findutils os package; used for housekeeping db backups
RUN set -ex \
      && apk add --update findutils sudo python sudo \
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

# Install ssh server
RUN apk --update add openssh-server openssh-client && mkdir /var/run/sshd && \
    ssh-keygen -A && \
    sed -i "s|#Port 22|Port 9000|" /etc/ssh/sshd_config && \
    sed -i 's|exec bin/neo4j console|mkdir -p ~/.ssh \&\& env > ~/.ssh/environment \&\& sudo bin/neo4j start \&\& sudo /usr/sbin/sshd -D|' /docker-entrypoint.sh && \
    sed -i "s|#PermitUserEnvironment no|PermitUserEnvironment yes|" /etc/ssh/sshd_config

# Copy the script and dummy 'service' command to emulate as neo4j service 
# This is to make the setup similar to an actual neo4j server (at least to the scripts)
COPY scripts/ ${WEBHOOK_INSTALL_PATH}/

# Update the files with the environment variables
RUN ${WEBHOOK_INSTALL_PATH}/update_vars.sh ${WEBHOOK_INSTALL_PATH}'/*.sh'

# Add path to the bin directory
ENV PATH=${PATH}:${WEBHOOK_INSTALL_PATH}:/var/lib/neo4j/bin

