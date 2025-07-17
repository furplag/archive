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

# Enshrouded ( steamapp )
ARG STEAMAPP_ID=2278520
ARG STEAMAPP_NAME=enshrouded
ARG STEAMAPP_HOME="${STEAM_HOME}/${STEAMAPP_NAME}"
ARG SteamAppId=1203620
ARG STEAMAPP_PLATFORM_TYPE=windows
ARG STEAMAPP_UPDATE_ENABLED='TRUE'

# Box64
ARG BOX64_NOBANNER=1
ARG BOX64_DYNAREC_BIGBLOCK=1
ARG BOX64_DYNAREC_BLEEDING_EDGE=0
ARG BOX64_DYNAREC_STRONGMEM=2
ARG BOX64_DYNAREC_CALLRET=1
ARG BOX64_DYNAREC_FASTROUND=1
ARG BOX64_DYNAREC_FASTNAN=1
ARG BOX64_DYNAREC_SAFEFLAGS=1
ARG BOX64_DYNAREC_X87DOUBLE=0
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
ENV STEAMAPP_UPDATE_ENABLED=${STEAMAPP_UPDATE_ENABLED}

ENV BOX64_NOBANNER=${BOX64_NOBANNER}
ENV BOX64_DYNAREC_BIGBLOCK=${BOX64_DYNAREC_BIGBLOCK}
ENV BOX64_DYNAREC_BLEEDING_EDGE=${BOX64_DYNAREC_BLEEDING_EDGE}
ENV BOX64_DYNAREC_STRONGMEM=${BOX64_DYNAREC_STRONGMEM}
ENV BOX64_DYNAREC_CALLRET=${BOX64_DYNAREC_CALLRET}
ENV BOX64_DYNAREC_FASTROUND=${BOX64_DYNAREC_FASTROUND}
ENV BOX64_DYNAREC_FASTNAN=${BOX64_DYNAREC_FASTNAN}
ENV BOX64_DYNAREC_SAFEFLAGS=${BOX64_DYNAREC_SAFEFLAGS}
ENV BOX64_DYNAREC_X87DOUBLE=${BOX64_DYNAREC_X87DOUBLE}
ENV BOX64_LOG=${BOX64_LOG}
ENV BOX64_TRACE_FILE=${BOX64_TRACE_FILE}

###
# process
###

# packages ( general )
WORKDIR /
USER root
RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && \
  apt-get autoremove -y && apt-get clean autoclean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists;

WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}
# startup
RUN for _script in 'enshrouded_server.aarch64' 'enshrouded_server.update'; do curl -fL "https://github.com/furplag/archive/raw/master/docker/enshrouded-aarch64.oci.ampere/${_script}" -o "${STEAM_HOME}/${_script}" && chmod +x "${STEAM_HOME}/${_script}"; done;

# ports
EXPOSE 15636/tcp
EXPOSE 15637/tcp
EXPOSE 15636/udp
EXPOSE 15637/udp

# user / directory
WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}

# entrypoint
ENTRYPOINT [ "bash", "enshrouded_server.aarch64" ]
