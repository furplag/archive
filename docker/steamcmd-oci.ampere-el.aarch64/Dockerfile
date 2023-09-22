FROM furplag/box86_64:latest

###
# steamcmd-oci.ampere-el.aarch64/Dockerfile
# https://github.com/furplag/archive/docker
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# a base Dockerfile that enable to use steamcmd on arm64/v8 instance ( especially for A1.Flex-ampere.OracleLinux  ) .
#
# Requirement
# a base image "furplag/box86_64:latest" should be build before this image .
# 
# Usage
# A. docker build https://github.com/furplag/archive/raw/master/docker/steamcmd-oci.ampere-el.aarch64/Dockerfile -t furplag/steamcmd:latest
# B. docker build https://github.com/furplag/archive/raw/master/docker/steamcmd-oci.ampere-el.aarch64/Dockerfile \
#     --build-arg STEAM_HOME='~/steam' \
#     ...
#     -t furplag/steamcmd:latest
# C. docker build https://github.com/furplag/archive/raw/master/docker/box86_64-oci.ampere-el.aarch64/Dockerfile -t furplag/box86_64:latest && \
#     docker build https://github.com/furplag/archive/raw/master/docker/steamcmd-oci.ampere-el.aarch64/Dockerfile -t furplag/steamcmd:latest
# D. curl -fLsS https://github.com/furplag/archive/raw/master/docker/steamcmd-oci.ampere-el.aarch64/Dockerfile \
#     | sed -e 's/^FROM.*$/FROM {a base image that Box86/Box64 executable}/' | docker build -t furplag/steamcmd:latest -
#    ( should set system-wide Environment "DEBUGGER" has path to Box86 . )
#

###
# ENV / variable
###

ARG STEAM_HOME="/opt/steam"
ARG STEAMCMD_HOME="${STEAM_HOME}/steamcmd"
ARG STEAM_LIBS_86="${STEAMCMD_HOME}/linux32"
ARG STEAM_LIBS_64="${STEAMCMD_HOME}/linux64"
ARG DEBUGGER="/usr/local/bin/box86"

ENV STEAM_HOME ${STEAM_HOME}
ENV STEAMCMD_HOME=${STEAMCMD_HOME}
ENV STEAM_LIBS_86 ${STEAM_LIBS_86}
ENV STEAM_LIBS_64 ${STEAM_LIBS_64}
ENV DEBUGGER ${DEBUGGER}

###
# process
###
# packages
RUN \
  apt-get update && apt-get upgrade && apt-get dist-upgrade -y && \
  DEBIAN_FRONTEND=noninteractive && apt-get install -y curl;

# steamcmd
WORKDIR ${STEAM_HOME}
RUN mkdir -p ${STEAMCMD_HOME} && \
  curl -fL https://github.com/furplag/archive/raw/master/docker/steamcmd-oci.ampere-el.aarch64/{steamcmd.update} -o ${STEAM_HOME}/#1;

RUN [ -f "${STEAM_HOME}/steamcmd.update" ] && chmod +x ${STEAM_HOME}/steamcmd.update;

WORKDIR ${STEAMCMD_HOME}
RUN curl -fsSqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxvf -;

WORKDIR ${STEAM_HOME}
RUN cat ${STEAM_HOME}/steamcmd.update | bash;

# cleanup
RUN apt-get autoremove --purge -y curl;
RUN rm -rf ~/Steam;

WORKDIR ${STEAM_HOME}
