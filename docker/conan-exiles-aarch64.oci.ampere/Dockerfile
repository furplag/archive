FROM furplag/steamcmd:latest
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
ARG STEAMAPP_NAME=conanExiles
ARG STEAMAPP_HOME="${STEAM_HOME}/${STEAMAPP_NAME}"
ARG SteamAppId=440900
ARG STEAMAPP_PLATFORM_TYPE=windows
ARG STEAMAPP_LOG_DIR="${STEAM_HOME}/_logs"

ARG CONAN_EXILES_SERVER_UPDATE_ENABLED='TRUE'

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

###
# process
###

# packages ( general )
WORKDIR /
USER root

# packages
RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y;
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl dialog winbind xfce4 xfce4-session xvfb xz-utils;

# Pi-Apps
WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}
RUN echo 'xfce4-session' >${STEAM_HOME}/.xsession;
RUN curl -fLsS https://raw.githubusercontent.com/Botspot/pi-apps/master/install | bash;

# Wine
RUN xvfb-run -a pi-apps/manage install 'Wine (x64)';
# Wine ( box64 environment )
RUN echo '[/usr/local/bin/wine]' >${STEAM_HOME}/.box64rc;
RUN echo "BOX64_DYNAREC_BIGBLOCK=${BOX64_DYNAREC_BIGBLOCK:-1}" >>${STEAM_HOME}/.box64rc;
RUN echo "BOX64_DYNAREC_BLEEDING_EDGE=${BOX64_DYNAREC_BLEEDING_EDGE:-0}" >>${STEAM_HOME}/.box64rc;
RUN echo "BOX64_DYNAREC_STRONGMEM=${BOX64_DYNAREC_STRONGMEM:-2}" >>${STEAM_HOME}/.box64rc;
RUN [ ${BOX64_LOG:-0} -ne 0 ] && echo "BOX64_LOG=${BOX64_LOG}" >>${STEAM_HOME}/.box64rc;
RUN [ ${BOX64_LOG:-0} -ne 0 ] && [ -n "${BOX64_LOG_DIR:-}" ] && mkdir -p "${BOX64_LOG_DIR}";
RUN [ ${BOX64_LOG:-0} -ne 0 ] && [ -n "${BOX64_LOG_DIR:-}" ] && [ -n "${BOX64_LOG_FILE:-}" ] && echo "BOX64_TRACE_FILE=${BOX64_LOG_DIR}/${BOX64_LOG_FILE}.log" >>${HOME}/.box64rc;

# startup
RUN for _script in 'conan_exiles_server.aarch64' 'conan_exiles_server.update'; do curl -fL "https://github.com/furplag/archive/raw/master/docker/conan-exiles-aarch64.oci.ampere/${_script}" -o "${STEAM_HOME}/${_script}" && chmod +x "${STEAM_HOME}/${_script}"; done;

# cleanup
WORKDIR /
USER root
RUN apt-get autoremove -y;
RUN apt-get clean autoclean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists;

# ports
EXPOSE 7777/tcp
EXPOSE 25575/tcp
EXPOSE 7777/udp
EXPOSE 7778/udp
EXPOSE 27015/udp

# current user / directory
WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}

# entrypoint
ENTRYPOINT [ "bash", "conan_exiles_server.aarch64" ]
