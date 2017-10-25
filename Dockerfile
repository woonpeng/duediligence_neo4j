################################################################################
# Placeholder for until official neo4j:3.3.0 is pushed to Docker Hub
# https://github.com/neo4j/docker-neo4j-publish/blob/master/3.3.0/community/Dockerfile

FROM openjdk:8-jre-alpine

RUN apk add --no-cache --quiet \
    bash \
    curl

ENV NEO4J_SHA256=dbbc65683d65018c48fc14d82ee7691ca75f8f6ea79823b21291970638de5d88 \
    NEO4J_TARBALL=neo4j-community-3.3.0-unix.tar.gz
ARG NEO4J_URI=http://dist.neo4j.org/neo4j-community-3.3.0-unix.tar.gz

COPY ./local-package/* /tmp/

RUN curl --fail --silent --show-error --location --remote-name ${NEO4J_URI} \
    && echo "${NEO4J_SHA256}  ${NEO4J_TARBALL}" | sha256sum -csw - \
    && tar --extract --file ${NEO4J_TARBALL} --directory /var/lib \
    && mv /var/lib/neo4j-* /var/lib/neo4j \
    && rm ${NEO4J_TARBALL} \
    && mv /var/lib/neo4j/data /data \
    && ln -s /data /var/lib/neo4j/data \
    && apk del curl

WORKDIR /var/lib/neo4j

VOLUME /data

COPY docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 7474 7473 7687

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["neo4j"]

# Install findutils os package; used for housekeeping db backups
RUN set -ex \
      && apk add --update findutils sudo python curl \
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
RUN ${EXTENSION_INSTALL_PATH}/update_vars.sh ${EXTENSION_INSTALL_PATH}'/*.sh'

# Add path to the bin directory
ENV PATH=${PATH}:${EXTENSION_INSTALL_PATH}:/var/lib/neo4j/bin
