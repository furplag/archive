FROM furplag/box86_64:latest
###
# minecraft/bedrock-oci.ampere-el.aarch64/Dockerfile
# https://github.com/furplag/archive/docker
#
# running Valheim dedicated server on arm64/v8 instance ( especially for A1.Flex-ampere.OracleLinux  ) .
#
# Requirement
# [ ] a base image "furplag/box86_64:latest" should be build before this image .
# [ ] a Docker Volume to persists game data ( recommends to use docker compose ) .
#
# NOTE:
# auto update is currently unsupported yet, following step to migrate data .
# 1. start container once .
# 2. stop container and overwrite data from previous version to current version at "Volume" in docker host .
#    * ${BEDROCK_SERVER_ROOT}/worlds ( directory )
#    * ${BEDROCK_SERVER_ROOT}/allowlist.json
#    * ${BEDROCK_SERVER_ROOT}/permissions.json
#    * ${BEDROCK_SERVER_ROOT}/server.properties
# 3. regenerate ( docker compose ) container with newer environment, or modify container environment
#    in file: /var/lib/docker/containers/{container_id}/config.v2.json
#    "Env":[ environment ... ]
#

###
# ENV / variable
###
ARG LANG="en_US.UTF-8"
ARG TZ="UTC"

ARG MINECRAFT_USER='minecraft'
ARG MINECRAFT_USER_ID='1001'

ARG MINECRAFT_HOME="/opt/${MINECRAFT_USER}"

ARG BEDROCK_VERSION='1.20.50.03'
ARG BEDROCK_SRC="https://minecraft.azureedge.net/bin-linux/bedrock-server-${BEDROCK_VERSION}.zip"
ARG BEDROCK_PORT='19132-19133'
ARG BEDROCK_SERVER_ROOT="${MINECRAFT_HOME}/bedrock-server-${BEDROCK_VERSION}"
ARG BEDROCK_SERVER_CONFIG_DEFAULT="${MINECRAFT_HOME}/.config.default/${BEDROCK_VERSION}"

ENV LANG ${LANG}
ENV TZ ${TZ}

ENV MINECRAFT_HOME ${MINECRAFT_HOME}
ENV BEDROCK_VERSION ${BEDROCK_VERSION}
ENV BEDROCK_SERVER_ROOT ${BEDROCK_SERVER_ROOT}

# packages
WORKDIR /
RUN apt-get update && apt-get upgrade && apt-get dist-upgrade -y && \
  DEBIAN_FRONTEND=noninteractive; apt-get install -y \
  curl libcurl4 locales unzip;

# localization
RUN sed -i -E "s/^# (en_US.UTF-8|${LANG})/\1/g" /etc/locale.gen && locale-gen;

# user / group
RUN useradd -m -u ${MINECRAFT_USER_ID} -d ${MINECRAFT_HOME} -s /bin/bash ${MINECRAFT_USER};

# install server
RUN \
  mkdir -p ${MINECRAFT_HOME}/.archive && \
  curl -fL ${BEDROCK_SRC} -o ${MINECRAFT_HOME}/.archive/bedrock-server-${BEDROCK_VERSION}.zip && \
  unzip ${MINECRAFT_HOME}/.archive/bedrock-server-${BEDROCK_VERSION}.zip -d ${BEDROCK_SERVER_ROOT};

# save default config
RUN \
  mkdir -p "${BEDROCK_SERVER_CONFIG_DEFAULT}" && \
  cp -pr "${BEDROCK_SERVER_ROOT}/allowlist.json" "${BEDROCK_SERVER_CONFIG_DEFAULT}/." && \
  cp -pr "${BEDROCK_SERVER_ROOT}/permissions.json" "${BEDROCK_SERVER_CONFIG_DEFAULT}/." && \
  cp -pr "${BEDROCK_SERVER_ROOT}/server.properties" "${BEDROCK_SERVER_CONFIG_DEFAULT}/.";

COPY bedrock_server.aarch64 ${MINECRAFT_HOME}
RUN chown -R ${MINECRAFT_USER}:${MINECRAFT_USER} ${MINECRAFT_HOME} && \
  chmod +x ${MINECRAFT_HOME}/bedrock_server.aarch64;

# cleanup image
RUN rm -rf ${MINECRAFT_HOME}/.archive;
RUN apt-get autoremove --purge -y curl unzip;
RUN rm -rf /var/lib/apt/lists/*;

EXPOSE ${BEDROCK_PORT}/udp

WORKDIR ${MINECRAFT_HOME}
VOLUME [ "${MINECRAFT_HOME}" ]

WORKDIR ${MINECRAFT_HOME}
USER ${MINECRAFT_USER}

ENTRYPOINT [ "bash", "bedrock_server.aarch64" ]
