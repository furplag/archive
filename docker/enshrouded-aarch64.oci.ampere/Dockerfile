FROM furplag/steamcmd-wined:latest
###
# enshrouded-aarch64.oci.ampere/Dockerfile
# https://github.com/furplag/archive/docker
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# running Enshrouded dedicated server on arm64/v8 instance ( especially for A1.Flex-ampere.OracleLinux  ) .
#
# Requirement
# [ ] a base image "furplag/steamcmd-wined:latest" should be build before this image .
# [ ] a Docker Volume to persists game data ( recommends to use docker compose ) .
#
# Usage
#

###
# ENV / variable
###
# general
ARG TZ=Etc/UTC
ARG LANG='en_US.UTF-8'
ARG LANGUAGE='en_US:en'

# steamcmd
ARG STEAM_HOME=/opt/steam
ARG STEAM_USER=steam
ARG STEAMCMD_HOME="${STEAM_HOME}/steamcmd"
ARG STEAM_LIBS_86="${STEAMCMD_HOME}/linux32"
ARG STEAM_LIBS_64="${STEAMCMD_HOME}/linux64"

# Conan Exiles ( steamapp )
ARG STEAMAPP_ID=2278520
ARG STEAMAPP_NAME=enshrouded
ARG STEAMAPP_HOME="${STEAM_HOME}/${STEAMAPP_NAME}"
ARG SteamAppId=1203620
ARG STEAMAPP_PLATFORM_TYPE=windows
ARG STEAMAPP_LOG_DIR="${STEAM_HOME}/_logs"
ARG STEAMAPP_UPDATE_ENABLED='TRUE'

# Conan Exiles ( box64 ( wine ) options )
ARG BOX64_DYNAREC_BIGBLOCK=1
ARG BOX64_DYNAREC_BLEEDING_EDGE=0
ARG BOX64_DYNAREC_STRONGMEM=2
ARG BOX64_LOG=1
ARG BOX64_LOG_DIR="${STEAMAPP_LOG_DIR}"
ARG BOX64_LOG_FILE="Box64-${STEAMAPP_NAME}.log"

ARG BOX86_NOBANNER=1
ARG BOX64_NOBANNER=1

ENV TZ=${TZ}
ENV LANG=${LANG}
ENV LANGUAGE=${LANGUAGE}

ENV STEAM_HOME=${STEAM_HOME}
ENV STEAM_USER=${STEAM_USER}
ENV STEAMCMD_HOME=${STEAMCMD_HOME}
ENV STEAM_LIBS_86=${STEAM_LIBS_86}
ENV STEAM_LIBS_64=${STEAM_LIBS_64}

ENV STEAMAPP_ID=${STEAMAPP_ID}
ENV STEAMAPP_NAME=${STEAMAPP_NAME}
ENV STEAMAPP_HOME=${STEAMAPP_HOME}
ENV SteamAppId=${SteamAppId}
ENV STEAMAPP_PLATFORM_TYPE=${STEAMAPP_PLATFORM_TYPE}
ENV STEAMAPP_LOG_DIR=${STEAMAPP_LOG_DIR}
ENV STEAMAPP_UPDATE_ENABLED=${STEAMAPP_UPDATE_ENABLED}

###
# process
###

WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}

RUN echo '[/usr/local/bin/wine]' >${STEAM_HOME}/.box64rc;
RUN echo "BOX64_DYNAREC_BIGBLOCK=${BOX64_DYNAREC_BIGBLOCK:-1}" >>${STEAM_HOME}/.box64rc;
RUN echo "BOX64_DYNAREC_BLEEDING_EDGE=${BOX64_DYNAREC_BLEEDING_EDGE:-0}" >>${STEAM_HOME}/.box64rc;
RUN echo "BOX64_DYNAREC_STRONGMEM=${BOX64_DYNAREC_STRONGMEM:-2}" >>${STEAM_HOME}/.box64rc;
RUN [ ${BOX64_LOG:-0} -ne 0 ] && echo "BOX64_LOG=${BOX64_LOG}" >>${STEAM_HOME}/.box64rc;
RUN [ ${BOX64_LOG:-0} -ne 0 ] && [ -n "${BOX64_LOG_DIR:-}" ] && [ -n "${BOX64_LOG_FILE:-}" ] && echo "BOX64_TRACE_FILE=${BOX64_LOG_DIR}/${BOX64_LOG_FILE}.log" >>${HOME}/.box64rc;

# startup
RUN for _script in 'enshrouded_server.aarch64' 'enshrouded_server.update'; do curl -fL "https://github.com/furplag/archive/raw/master/docker/enshrouded-aarch64.oci.ampere/${_script}" -o "${STEAM_HOME}/${_script}" && chmod +x "${STEAM_HOME}/${_script}"; done;

# cleanup
WORKDIR /
USER root
RUN apt-get autoremove -y;
RUN apt-get clean autoclean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists;

# ports
EXPOSE 15636/tcp
EXPOSE 15637/tcp
EXPOSE 15636/udp
EXPOSE 15637/udp

# current user / directory
WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}

# entrypoint
ENTRYPOINT [ "bash", "enshrouded_server.aarch64" ]
