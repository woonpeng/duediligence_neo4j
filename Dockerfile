FROM neo4j:4.0.2
ENV NEO4J_AUTH=neo4j/test

# Install findutils os package; used for housekeeping db backups
RUN   apt update && apt install -y dos2unix findutils sudo python curl \
      && curl "https://bootstrap.pypa.io/get-pip.py" | python && pip install j2cli

# Arguments
ARG EXTENSION_INSTALL_PATH

# Set installation options that will be used to update the scripts
# Modify config.json in scripts directory for the other configurations
ENV EXTENSION_INSTALL_PATH ${EXTENSION_INSTALL_PATH:-"/opt/neo4j-extension"}

# Install ssh server and start the service
RUN apt install -y openssh-server openssh-client && mkdir /var/run/sshd && \
    passwd -u root && \
    ssh-keygen -A && \
    mkdir -p /root/.ssh/ && \
    sed -i 's|exec bin/neo4j console|mkdir -p ~/.ssh \&\& env > ~/.ssh/environment \&\& chown -R root:root ~/.ssh \&\& bin/neo4j start \&\& /usr/sbin/sshd -D|' /docker-entrypoint.sh && \
    sed -i "s|#PermitUserEnvironment no|PermitUserEnvironment yes|" /etc/ssh/sshd_config && \
    sed -i "s|#UsePAM no|UsePAM yes|" /etc/ssh/sshd_config && \
    sed -i "s|#PasswordAuthentication yes|PasswordAuthentication no|" /etc/ssh/sshd_config

# Copy public key for ansible deployment
COPY authorized_keys /root/.ssh/

# Copy the script and dummy 'service' command to emulate as neo4j service
# This is to make the setup similar to an actual neo4j server (at least to the scripts)
COPY scripts/ ${EXTENSION_INSTALL_PATH}/

# Update the files with the environment variables
RUN ${EXTENSION_INSTALL_PATH}/update_vars.sh ${EXTENSION_INSTALL_PATH}'/*.sh'

# Add path to the bin directory
ENV PATH=${PATH}:${EXTENSION_INSTALL_PATH}:/var/lib/neo4j/bin
