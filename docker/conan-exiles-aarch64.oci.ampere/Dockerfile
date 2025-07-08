FROM furplag/steamcmd-wined:latest
###
# conan-exiles-aarch64.oci.ampere/Dockerfile
# https://github.com/furplag/archive/docker
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# running Conan Exile dedicated server on arm64/v8 instance ( especially for A1.Flex-ampere.OracleLinux  ) .
#
# Requirement
# [ ] a base image "furplag/steamcmd:latest" should be build before this image .
# [ ] a Docker Volume to persists game data ( recommends to use docker compose ) .
#
# Usage
# A. docker compose up -d --name {container} \
#    -p 7777:7777/udp \
#    -p 7777:7778/udp \
#    -p 27015:27015/udp \
#    -p 18888:18888/tcp \
#    server
#

###
# ENV / variable
###e
# general
ARG DEBIAN_FRONTEND=noninteractive
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
ARG STEAMAPP_ID=443030
ARG STEAMAPP_NAME=conan-exiles
ARG STEAMAPP_HOME="${STEAM_HOME}/${STEAMAPP_NAME}"
ARG SteamAppId=440900
ARG STEAMAPP_PLATFORM_TYPE=windows
ARG STEAMAPP_LOG_DIR="${STEAM_HOME}/_logs"
ARG STEAMAPP_UPDATE_ENABLED='TRUE'

ARG BOX64_NOBANNER=1
ARG BOX64_DYNAREC_BIGBLOCK=0
ARG BOX64_DYNAREC_BLEEDING_EDGE=0
ARG BOX64_DYNAREC_STRONGMEM=2
ARG BOX64_LOG=0
ARG BOX64_TRACE_FILE=

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

ENV BOX64_NOBANNER=${BOX64_NOBANNER}
ENV BOX64_DYNAREC_BIGBLOCK=${BOX64_DYNAREC_BIGBLOCK}
ENV BOX64_DYNAREC_BLEEDING_EDGE=${BOX64_DYNAREC_BLEEDING_EDGE}
ENV BOX64_DYNAREC_STRONGMEM=${BOX64_DYNAREC_STRONGMEM}
ENV BOX64_LOG=${BOX64_TRACE_FILE}
ENV BOX64_TRACE_FILE=${BOX64_TRACE_FILE}

###
# process
###

# packages ( general )
WORKDIR /
USER root
RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && \
  apt-get autoremove --purge -y && apt-get clean autoclean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists;

WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}
# startup
RUN for _script in 'conan_exiles_server.aarch64' 'conan_exiles_server.update'; do curl -fL "https://github.com/furplag/archive/raw/master/docker/conan-exiles-aarch64.oci.ampere/${_script}" -o "${STEAM_HOME}/${_script}" && chmod +x "${STEAM_HOME}/${_script}"; done;

# ports
EXPOSE 7777/tcp
EXPOSE 25575/tcp
EXPOSE 7777/udp
EXPOSE 7778/udp
EXPOSE 27015/udp

# user / directory
WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}

# entrypoint
ENTRYPOINT [ "bash", "conan_exiles_server.aarch64" ]
