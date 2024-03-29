FROM furplag/steamcmd:latest
###
# wined-valheim-aarch64.oci.ampere/Dockerfile
# https://github.com/furplag/archive/docker
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# running Valheim dedicated server on arm64/v8 instance ( especially for A1.Flex-ampere.OracleLinux  ) .
#
# Requirement
# [ ] a base image "furplag/steamcmd:latest" should be build before this image .
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
ARG VALHEIM_PASSWORD='s3CRet'
ARG VALHEIM_PORT='2456'
ARG VALHEIM_PORT_ASIDE='2457'
ARG VALHEIM_IS_PUBLIC='FALSE'
ARG VALHEIM_CROSSPLAY_ENABLED='FALSE'
ARG VALHEIM_SAVE_DIR="${VALHEIM_HOME}/_saves"
ARG VALHEIM_SAVE_INTERVAL='1800'
ARG VALHEIM_BACKUPS='4'
ARG VALHEIM_BACKUP_SHORT='7200'
ARG VALHEIM_BACKUP_LONG='43200'
ARG VALHEIM_LOG_DIR="${VALHEIM_HOME}/_logs"

ARG VALHEIM_MODIFIER_COMBAT=
ARG VALHEIM_MODIFIER_DEATHPENALTY=
ARG VALHEIM_MODIFIER_PORTALS=
ARG VALHEIM_MODIFIER_RAIDS=
ARG VALHEIM_MODIFIER_RESOURCES=

ARG VALHEIM_MODIFIER_NOBUILDCOST='FALSE'
ARG VALHEIM_MODIFIER_PLAYEREVENTS='FALSE'
ARG VALHEIM_MODIFIER_PASSIVEMOBS='FALSE'
ARG VALHEIM_MODIFIER_NOMAP='FALSE'

ARG VALHEIM_SERVER_UPDATE_ENABLED='TRUE'

ARG BOX64_DYNAREC_BIGBLOCK='2'
ARG BOX64_DYNAREC_BLEEDING_EDGE='0'
ARG BOX64_DYNAREC_STRONGMEM='4'

ENV TZ ${TZ}

ENV STEAM_HOME ${STEAM_HOME}
ENV DEBUGGER ${DEBUGGER}
ENV VALHEIM_HOME ${VALHEIM_HOME}

ENV VALHEIM_APP_ID ${VALHEIM_APP_ID}
ENV VALHEIM_STEAMAPP_ID ${VALHEIM_STEAMAPP_ID}

ENV VALHEIM_NAME ${VALHEIM_NAME}
ENV VALHEIM_WORLD ${VALHEIM_WORLD}
ENV VALHEIM_PASSWORD ${VALHEIM_PASSWORD}
ENV VALHEIM_PORT ${VALHEIM_PORT}
ENV VALHEIM_PORT_ASIDE ${VALHEIM_PORT_ASIDE}
ENV VALHEIM_IS_PUBLIC ${VALHEIM_IS_PUBLIC}
ENV VALHEIM_CROSSPLAY_ENABLED ${VALHEIM_CROSSPLAY_ENABLED}
ENV VALHEIM_SAVE_DIR ${VALHEIM_SAVE_DIR}
ENV VALHEIM_SAVE_INTERVAL ${VALHEIM_SAVE_INTERVAL}
ENV VALHEIM_BACKUPS ${VALHEIM_BACKUPS}
ENV VALHEIM_BACKUP_SHORT ${VALHEIM_BACKUP_SHORT}
ENV VALHEIM_BACKUP_LONG ${VALHEIM_BACKUP_LONG}
ENV VALHEIM_LOG_DIR ${VALHEIM_LOG_DIR}
ENV VALHEIM_MODIFIER_COMBAT ${VALHEIM_MODIFIER_COMBAT}
ENV VALHEIM_MODIFIER_DEATHPENALTY ${VALHEIM_MODIFIER_DEATHPENALTY}
ENV VALHEIM_MODIFIER_PORTALS ${VALHEIM_MODIFIER_PORTALS}
ENV VALHEIM_MODIFIER_RAIDS ${VALHEIM_MODIFIER_RAIDS}
ENV VALHEIM_MODIFIER_RESOURCES ${VALHEIM_MODIFIER_RESOURCES}
ENV VALHEIM_MODIFIER_NOBUILDCOST ${VALHEIM_MODIFIER_NOBUILDCOST}
ENV VALHEIM_MODIFIER_PLAYEREVENTS ${VALHEIM_MODIFIER_PLAYEREVENTS}
ENV VALHEIM_MODIFIER_PASSIVEMOBS ${VALHEIM_MODIFIER_PASSIVEMOBS}
ENV VALHEIM_MODIFIER_NOMAP ${VALHEIM_MODIFIER_NOMAP}
ENV VALHEIM_SERVER_UPDATE_ENABLED ${VALHEIM_SERVER_UPDATE_ENABLED}

# packages
WORKDIR /
USER root
RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y;
RUN apt-get install -y curl sudo \
  libasyncns0 libatomic1 libglib2.0-0 libpulse0 libpulse-dev libpulse-mainloop-glib0 libsdl2-2.0-0;

# scripts
WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}
RUN curl -fL https://github.com/furplag/archive/raw/master/docker/valheim-aarch64.oci.ampere/{valheim_server.aarch64} -o ${STEAM_HOME}/#1;
RUN curl -fL https://github.com/furplag/archive/raw/master/docker/valheim-aarch64.oci.ampere/{valheim_server.update} -o ${STEAM_HOME}/#1;
RUN chmod +x ${STEAM_HOME}/valheim_server.*;

# box64 environment
RUN echo '' > ~/.box64rc;
RUN echo '[valheim_server.x86_64]' >> ~/.box64rc;
RUN echo "BOX64_DYNAREC_BIGBLOCK=${BOX64_DYNAREC_BIGBLOCK}" >> ~/.box64rc;
RUN echo "BOX64_DYNAREC_BLEEDING_EDGE=${BOX64_DYNAREC_BLEEDING_EDGE}" >> ~/.box64rc;
RUN echo "BOX64_DYNAREC_STRONGMEM=${BOX64_DYNAREC_STRONGMEM}" >> ~/.box64rc;
RUN echo '' >> ~/.box64rc;

# cleanup image
WORKDIR /
USER root
RUN apt-get autoremove --purge -y ;
RUN apt-get clean autoclean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists;

# ports
EXPOSE ${VALHEIM_PORT}-${VALHEIM_PORT_ASIDE}/udp

WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}

# entrypoint
ENTRYPOINT [ "bash", "/opt/steam/valheim_server.aarch64" ]
