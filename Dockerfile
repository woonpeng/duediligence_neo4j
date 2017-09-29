FROM neo4j:3.1.3

# Install findutils os package; used for housekeeping db backups
RUN set -ex \
      && apk add --update findutils sudo python \
      && curl "https://bootstrap.pypa.io/get-pip.py" | python && pip install j2cli

# Arguments
ARG EXTENSION_INSTALL_PATH

# Set installation options that will be used to update the scripts
# Modify config.json in scripts directory for the other configurations
ENV EXTENSION_INSTALL_PATH ${EXTENSION_INSTALL_PATH:-"/opt/neo4j-extension"}

# Install ssh server
RUN apk --update add openssh-server openssh-client && mkdir /var/run/sshd && \
    ssh-keygen -A && \
    mkdir -p /root/.ssh/ && \
    sed -i 's|exec bin/neo4j console|mkdir -p ~/.ssh \&\& env > ~/.ssh/environment \&\& bin/neo4j start \&\& /usr/sbin/sshd -D|' /docker-entrypoint.sh && \
    sed -i "s|#PermitUserEnvironment no|PermitUserEnvironment yes|" /etc/ssh/sshd_config

# Copy public key for ansible deployment
COPY authorized_keys /root/.ssh/

# Copy the script and dummy 'service' command to emulate as neo4j service
# This is to make the setup similar to an actual neo4j server (at least to the scripts)
COPY scripts/ ${EXTENSION_INSTALL_PATH}/

# Update the files with the environment variables
WORKDIR ${EXTENSION_INSTALL_PATH}
RUN ${EXTENSION_INSTALL_PATH}/update_vars.sh ${EXTENSION_INSTALL_PATH}'/*.sh'

# Add path to the bin directory
ENV PATH=${PATH}:${EXTENSION_INSTALL_PATH}:/var/lib/neo4j/bin
