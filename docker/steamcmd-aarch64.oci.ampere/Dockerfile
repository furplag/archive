FROM debian:trixie-slim

###
# steamcmd-aarch64.oci.ampere/Dockerfile
# https://github.com/furplag/archive/docker
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# a base Dockerfile that enable to use steamcmd on arm64/v8 instance ( with Box86 / 64, especially for A1.Flex-ampere.OracleLinux ) .
#
# Usage
# A. docker build https://github.com/furplag/archive/raw/master/docker/steamcmd-aarch64.oci.ampere/Dockerfile -t furplag/steamcmd:latest
# B. docker build https://github.com/furplag/archive/raw/master/docker/steamcmd-aarch64.oci.ampere/Dockerfile \
#     --build-arg STEAM_HOME='~/steam' \
#     ...
#     -t furplag/steamcmd:latest
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
RUN dpkg --add-architecture armhf && apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y;
RUN apt-get install -y curl gnupg sudo;

# add Box86 / 64 repositories
RUN curl -fL https://ryanfortner.github.io/box64-debs/{box64.list} -o /etc/apt/sources.list.d/#1;
RUN curl -fL https://ryanfortner.github.io/box86-debs/{box86.list} -o /etc/apt/sources.list.d/#1;
RUN curl -fLsS https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
RUN curl -fLsS https://ryanfortner.github.io/box86-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg

# install Box86 / 64 with dependencies
RUN apt-get update && apt-get install --install-recommends -y \
  ca-certificates gcc-arm-linux-gnueabihf libc6-dev-armhf-cross libc6:armhf libncurses6:armhf libstdc++6:armhf \
  box86-generic-arm box64-arm64;

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
RUN chmod +x ${STEAM_HOME}/steamcmd.update;
RUN cat ${STEAM_HOME}/steamcmd.update | bash;

# cleanup
WORKDIR /
USER root
RUN apt-get autoremove -y;
RUN apt-get clean autoclean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists;

WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}
