FROM ubuntu:noble

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
# general
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Etc/UTC
ARG LANG='en_US.UTF-8'
ARG LANGUAGE='en_US:en'

# steamcmd
ARG STEAM_HOME=/opt/steam
ARG STEAM_USER=steam
ARG STEAM_USER_ID=12001
ARG STEAM_GROUP_ID=12001

ARG BOX86_PACKAGE=box86-generic-arm
ARG BOX64_PACKAGE=box64-generic-arm

ENV TZ ${TZ}
ENV LANG ${LANG}
ENV LANGUAGE ${LANGUAGE}

ENV STEAM_HOME ${STEAM_HOME}
ENV STEAMCMD_HOME ${STEAM_HOME}/steamcmd
ENV STEAM_LIBS_86 ${STEAMCMD_HOME}/linux32
ENV STEAM_LIBS_64 ${STEAMCMD_HOME}/linux64

###
# process
###
# packages ( general )
RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y;
RUN DEBIAN_FRONTEND=noninteractive TZ=${TZ} apt-get install -y ca-certificates curl gnupg locales sudo tar tzdata;
RUN locale-gen ${LANG} && dpkg-reconfigure --frontend noninteractive locales;
RUN if [ -f "/usr/share/zoneinfo/${TZ}" ]; then ln -fns /usr/share/zoneinfo/${TZ} /etc/localtime; dpkg-reconfigure --frontend noninteractive tzdata; fi;

# add Box86 / 64 repositories
RUN for _box in 86 64; do \
  curl -fLsS https://Pi-Apps-Coders.github.io/box${_box}-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box${_box}-debs-archive-keyring.gpg; \
  curl -fL https://Pi-Apps-Coders.github.io/box${_box}-debs/box${_box}.list -o /etc/apt/sources.list.d/box${_box}.list; \
  done;
RUN dpkg --add-architecture armhf && apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y;

# install box86 / 64 with dependencies
RUN apt-get install -y \
  gcc-arm-linux-gnueabihf libc6-dev-armhf-cross \
  libc6:armhf libcal3d12t64:armhf libcups2t64:armhf libcurl4t64:armhf libncurses6:armhf \
  libegl1:armhf libgdk-pixbuf2.0-0:armhf libgl1:armhf libgles2:armhf libglx-mesa0:armhf \
  libgssapi-krb5-2:armhf libgtk-3-0t64:armhf libgtk2.0-0t64:armhf libjpeg62:armhf libkrb5-3:armhf \
  libopenal1:armhf libpng16-16t64:armhf libsdl-image1.2:armhf libsdl-mixer1.2:armhf \
  libsdl-net1.2:armhf libsdl-sound1.2:armhf libsdl-ttf2.0-0:armhf libsdl1.2debian:armhf \
  libsdl2-2.0-0:armhf libsdl2-image-2.0-0:armhf libsdl2-net-2.0-0:armhf libsdl2-ttf-2.0-0:armhf \
  libsmpeg0t64:armhf libssh-gcrypt-4:armhf libssl3t64:armhf libstdc++6:armhf libudev1:armhf \
  libvorbisfile3:armhf libx11-6:armhf mesa-va-drivers:armhf osspd:armhf \
  ${BOX86_PACKAGE:-box86-generic-arm} ${BOX64_PACKAGE:-box64-generic-arm};

# user / group
RUN groupadd -g ${STEAM_GROUP_ID} ${STEAM_USER} && useradd -m -u ${STEAM_USER_ID} -g ${STEAM_GROUP_ID} -d ${STEAM_HOME} -s /bin/bash ${STEAM_USER} && usermod -aG sudo ${STEAM_USER};
RUN echo '%sudo ALL=NOPASSWD:ALL' >/etc/sudoers.d/999_${STEAM_USER};

# steamcmd
WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}
RUN for _script in steamcmd.update steamapp.update; do curl -fL https://github.com/furplag/archive/raw/master/docker/steamcmd-aarch64.oci.ampere/${_script} -o ${STEAM_HOME}/${_script} && chmod +x ${STEAM_HOME}/${_script}; done;
RUN mkdir -p ${STEAMCMD_HOME};

WORKDIR ${STEAMCMD_HOME}
USER ${STEAM_USER}
RUN curl -fsSqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxvf -;

WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}
RUN cat ${STEAM_HOME}/steamcmd.update | bash;

# cleanup
WORKDIR /
USER root
RUN apt-get autoremove -y;
RUN apt-get clean autoclean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists;

WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}
