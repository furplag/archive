FROM debian:bookworm-slim
###
# dbeaver/cloudbeaver-oci.ampere-el.aarch64/Dockerfile
# https://github.com/furplag/archive/docker
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# running CloudBeaver on arm64/v8 instance ( especially for A1.Flex-ampere.OracleLinux  ) .
#
# Requirement
# [ ] a Docker Volume to persists server data ( recommends to use docker compose ) .
#
# Usage
# A. docker compose up -d --name {container} \
#    -p ${LISTEN_PORT:-8978}:${CLOUDBEAVER_PORT:-8978}/tcp \
#    server
#

###
# ENV / variable
###

ARG LANG='en_US.UTF-8'
ARG TZ='UTC'

ARG JAVA_HOME='/opt/java/openjdk'

ARG CLOUDBEAVER_HOME='/opt/cloudbeaver'
ARG CLOUDBEAVER_GROUP='dbeaver'
ARG CLOUDBEAVER_GROUP_ID='1230'
ARG CLOUDBEAVER_USER='cloudbeaver'
ARG CLOUDBEAVER_USER_ID='1231'

ARG CLOUDBEAVER_PORT='8978'

ENV LANG ${LANG}
ENV TZ ${TZ}

ENV JAVA_HOME ${JAVA_HOME}
ENV CLOUDBEAVER_HOME ${CLOUDBEAVER_HOME}
ENV CLOUDBEAVER_GROUP ${CLOUDBEAVER_GROUP}
ENV CLOUDBEAVER_GROUP_ID ${CLOUDBEAVER_GROUP_ID}
ENV CLOUDBEAVER_USER ${CLOUDBEAVER_USER}
ENV CLOUDBEAVER_USER_ID ${CLOUDBEAVER_USER_ID}
ENV CLOUDBEAVER_PORT ${CLOUDBEAVER_PORT}

###
# process
###

# packages
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && \
  apt-get install -y bash locales;

# localization
RUN sed -i -E "s/^# (en_US.UTF-8|${LANG})/\1/g" /etc/locale.gen && locale-gen;

# cleanup
USER root
WORKDIR /opt
RUN rm -rf /var/lib/apt/lists/*;

# user / group
RUN groupadd -g ${CLOUDBEAVER_GROUP_ID} ${CLOUDBEAVER_GROUP} && \
  useradd -m -u ${CLOUDBEAVER_USER_ID} -s /bin/bash ${CLOUDBEAVER_USER} && \
  usermod -aG ${CLOUDBEAVER_GROUP} ${CLOUDBEAVER_USER};

# Java
COPY --from=eclipse-temurin:21.0.1_12-jdk-jammy ${JAVA_HOME} ${JAVA_HOME}
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Cloudbeaver
COPY --from=dbeaver/cloudbeaver:latest ${CLOUDBEAVER_HOME} ${CLOUDBEAVER_HOME}
RUN \
  chown -R ${CLOUDBEAVER_USER}:${CLOUDBEAVER_GROUP} ${CLOUDBEAVER_HOME} && \
  chmod -R 775 ${CLOUDBEAVER_HOME} && \
  chmod +x ${CLOUDBEAVER_HOME}/run-server.sh

WORKDIR ${CLOUDBEAVER_HOME}
EXPOSE ${CLOUDBEAVER_PORT}/tcp
VOLUME [ "${CLOUDBEAVER_HOME}" ]

USER ${CLOUDBEAVER_USER}
ENTRYPOINT [ "bash", "./run-server.sh" ]
