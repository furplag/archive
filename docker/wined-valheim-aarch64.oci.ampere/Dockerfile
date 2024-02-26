FROM furplag/steamcmd_wined:latest
###
# wined-valheim-aarch64.oci.ampere/Dockerfile
# https://github.com/furplag/archive/docker
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# running Valheim dedicated server ( Windows platform ) on arm64/v8 instance ( especially for A1.Flex-ampere.OracleLinux  ) .
#
# Requirement
# [ ] a base image "furplag/steamcmd_wined:latest" should be build before this image .
# [ ] a Docker Volume to persists game data ( recommends to use docker compose ) .
#
# Usage
# A. docker compose up -d --name {container} \
#    -p 2456-2457:2456-2457/tcp \
#    -p 2456-2457:2456-2457/udp \
#    server
#

###
# ENV / variable
###

ARG DEBIAN_FRONTEND='noninteractive'
ARG TZ="UTC"

ARG STEAM_HOME='/opt/steam'
ARG DEBUGGER='/usr/local/bin/box86'
ARG VALHEIM_HOME="${STEAM_HOME}/valheim"

ARG STEAM_USER='steam'
ARG STEAM_USER_ID='1201'
ARG STEAM_GROUP_ID='1201'

ARG VALHEIM_APP_ID='896660'
ARG VALHEIM_STEAMAPP_ID='892970'

ARG VALHEIM_NAME='Valheim'
ARG VALHEIM_WORLD='Dedicated'
ARG VALHEIM_PORT='2456'
ARG VALHEIM_PORT_ASIDE='2458'
ARG VALHEIM_PASSWORD='s3CRet'
ARG VALHEIM_SAVE_DIR="${VALHEIM_HOME}/_saves"
ARG VALHEIM_LOG_DIR="${VALHEIM_HOME}/_logs"
ARG VALHEIM_IS_PUBLIC='FALSE'
ARG VALHEIM_CROSSPLAY_ENABLED='TRUE'
ARG VALHEIM_SERVER_UPDATE_ENABLED='TRUE'

ENV TZ ${TZ}

ENV STEAM_HOME ${STEAM_HOME}
ENV DEBUGGER ${DEBUGGER}
ENV VALHEIM_HOME ${VALHEIM_HOME}

ENV VALHEIM_APP_ID ${VALHEIM_APP_ID}
ENV VALHEIM_STEAMAPP_ID ${VALHEIM_STEAMAPP_ID}

ENV VALHEIM_NAME ${VALHEIM_NAME}
ENV VALHEIM_WORLD ${VALHEIM_WORLD}
ENV VALHEIM_PORT ${VALHEIM_PORT}
ENV VALHEIM_PORT_ASIDE ${VALHEIM_PORT_ASIDE}
ENV VALHEIM_PASSWORD ${VALHEIM_PASSWORD}
ENV VALHEIM_SAVE_DIR ${VALHEIM_SAVE_DIR}
ENV VALHEIM_LOG_DIR ${VALHEIM_LOG_DIR}
ENV VALHEIM_IS_PUBLIC ${VALHEIM_IS_PUBLIC}
ENV VALHEIM_CROSSPLAY_ENABLED ${VALHEIM_CROSSPLAY_ENABLED}
ENV VALHEIM_SERVER_UPDATE_ENABLED ${VALHEIM_SERVER_UPDATE_ENABLED}

# packages
WORKDIR /
USER root
RUN dpkg --add-architecture armhf;
RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y;
RUN apt-get install -y curl sudo wget \
  libasyncns0 libatomic1 libglib2.0-0 libpulse0 libpulse-dev libpulse-mainloop-glib0 libsdl2-2.0-0 \
  libasyncns0:armhf libatomic1:armhf libglib2.0-0:armhf libpulse0:armhf libpulse-dev:armhf libpulse-mainloop-glib0:armhf libsdl2-2.0-0:armhf;

WORKDIR ${STEAM_HOME}
USER root
RUN curl -fL https://github.com/furplag/archive/raw/master/docker/wined-valheim-aarch64.oci.ampere/valheim_server.aarch64 -o ${STEAM_HOME}/valheim_server.aarch64;
RUN curl -fL https://github.com/furplag/archive/raw/master/docker/wined-valheim-aarch64.oci.ampere/valheim_server.update -o ${STEAM_HOME}/valheim_server.update;
RUN chmod +x ${STEAM_HOME}/valheim_server.*;
RUN chown -R ${STEAM_USER}:${STEAM_USER} ${STEAM_HOME};

WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}
RUN ${STEAM_HOME}/valheim_server.update;

# cleanup image
WORKDIR /
USER root
RUN apt-get clean autoclean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists ${STEAM_HOME}/.cache;

# ports
EXPOSE ${VALHEIM_PORT}-${VALHEIM_PORT_ASIDE}/udp

WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}

# entrypoint
ENTRYPOINT [ "bash", "/opt/steam/valheim_server.aarch64" ]
