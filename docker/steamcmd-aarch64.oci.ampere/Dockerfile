FROM furplag/box86_64:latest

###
# steamcmd-aarch64.oci.ampere/Dockerfile
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
# A. docker build https://github.com/furplag/archive/raw/master/docker/steamcmd-aarch64.oci.ampere/Dockerfile -t furplag/steamcmd:latest
# B. docker build https://github.com/furplag/archive/raw/master/docker/steamcmd-aarch64.oci.ampere/Dockerfile \
#     --build-arg STEAM_HOME='~/steam' \
#     ...
#     -t furplag/steamcmd:latest
# C. docker build https://github.com/furplag/archive/raw/master/docker/box86_64-aarch64.oci.ampere/Dockerfile -t furplag/box86_64:latest && \
#     docker build https://github.com/furplag/archive/raw/master/docker/steamcmd-aarch64.oci.ampere/Dockerfile -t furplag/steamcmd:latest
# D. curl -fLsS https://github.com/furplag/archive/raw/master/docker/steamcmd-aarch64.oci.ampere/Dockerfile \
#     | sed -e 's/^FROM.*$/FROM {a base image that Box86/Box64 executable}/' | docker build -t furplag/steamcmd:latest -
#    ( should set system-wide Environment "DEBUGGER" has path to Box86 . )
#

###
# ENV / variable
###
ARG DEBIAN_FRONTEND="noninteractive"

ARG STEAM_HOME="/opt/steam"
ARG DEBUGGER="/usr/local/bin/box86"

ARG STEAM_USER='steam'
ARG STEAM_USER_ID='1201'
ARG STEAM_GROUP_ID='1201'

ENV STEAM_HOME ${STEAM_HOME}
ENV STEAMCMD_HOME ${STEAM_HOME}/steamcmd
ENV STEAMCMDW_HOME ${STEAM_HOME}/steamcmd-wined
ENV STEAM_LIBS_86 ${STEAMCMD_HOME}/linux32
ENV STEAM_LIBS_64 ${STEAMCMD_HOME}/linux64
ENV DEBUGGER ${DEBUGGER}

###
# process
###
# packages
RUN apt-get update && apt-get upgrade && apt-get dist-upgrade -y;
RUN apt-get install -y curl sudo;

# user / group
RUN groupadd -g ${STEAM_GROUP_ID} ${STEAM_USER} && useradd -m -u ${STEAM_USER_ID} -g ${STEAM_GROUP_ID} -d ${STEAM_HOME} -s /bin/bash ${STEAM_USER} && usermod -aG sudo ${STEAM_USER};
RUN echo '%sudo ALL=NOPASSWD:ALL' >/etc/sudoers.d/999_steam;

# steamcmd
WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}
RUN curl -fL https://github.com/furplag/archive/raw/master/docker/steamcmd-aarch64.oci.ampere/{steamcmd.update} -o ${STEAM_HOME}/#1;
RUN mkdir -p ${STEAMCMD_HOME};

WORKDIR ${STEAMCMD_HOME}
USER ${STEAM_USER}
RUN curl -fsSqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxvf -;

WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}
RUN chmod +x ${STEAM_HOME}/steamcmd*.update;
RUN cat ${STEAM_HOME}/steamcmd.update | bash;

# cleanup
WORKDIR /
USER root
RUN apt-get clean autoclean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists;

WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}
