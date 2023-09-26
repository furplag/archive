FROM furplag/steamcmd:latest

###
# steamcmd-oci.ampere-el.aarch64/Dockerfile
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

ARG LANG="en_US.UTF-8"
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
ARG VALHEIM_PORT_ASIDE='2457'
ARG VALHEIM_PASSWORD='s3CRet'
ARG VALHEIM_SAVE_DIR="${VALHEIM_HOME}/_saves"
ARG VALHEIM_LOG_DIR="${VALHEIM_HOME}/_logs"
ARG VALHEIM_IS_PUBLIC='FALSE'
ARG VALHEIM_CROSSPLAY_ENABLED='FALSE'
ARG VALHEIM_SERVER_UPDATE_ENABLED='TRUE'

ENV LANG ${LANG}
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
RUN apt-get update && apt-get upgrade && apt-get dist-upgrade -y && \
  DEBIAN_FRONTEND=noninteractive && apt-get install -y \
  curl locales \
  libatomic1 libglib2.0-0 libpulse0 libpulse-dev libpulse-mainloop-glib0 libsdl2-2.0-0 \
  libatomic1:armhf libglib2.0-0:armhf libpulse0:armhf libpulse-dev:armhf libpulse-mainloop-glib0:armhf;

# localization
RUN sed -i -E "s/^# (en_US.UTF-8|${LANG})/\1/g" /etc/locale.gen && locale-gen;

###
# libs to run server ( WiP, uncomment if necesary ) .
###
#RUN mkdir -p "${VALHEIM_HOME}/.tmp/extracted" && \
# curl -fL http://ftp.de.debian.org/debian/pool/main/g/gcc-12/{libatomic1_12.2.0-14_amd64.deb} -o "${VALHEIM_HOME}/.tmp/#1" && \
# curl -fL http://ftp.de.debian.org/debian/pool/main/p/pulseaudio/{libpulse0_16.1+dfsg1-2+b1_amd64.deb} -o "${VALHEIM_HOME}/.tmp/#1" && \
# curl -fL http://ftp.de.debian.org/debian/pool/main/libs/libsdl2/{libsdl2-2.0-0_2.26.5+dfsg-1_amd64.deb} -o "${VALHEIM_HOME}/.tmp/#1";
# curl -fL http://ftp.de.debian.org/debian/pool/main/g/glib-d/{libglibd-2.0-0_2.3.0-3_amd64.deb} -o "${VALHEIM_HOME}/.tmp/#1" && \
# curl -fL http://ftp.de.debian.org/debian/pool/main/p/pulseaudio/{libpulse-mainloop-glib0_16.1+dfsg1-2+b1_amd64.deb} -o "${VALHEIM_HOME}/.tmp/#1";
#RUN for _deb in `ls ${VALHEIM_HOME}/.tmp/*.deb`; do dpkg -x "${_deb}" ${VALHEIM_HOME}/.tmp/extracted; done;
#RUN cp -pr ${VALHEIM_HOME}/.tmp/extracted/usr/lib/x86_64-linux-gnu/* ${VALHEIM_HOME}/.;
#RUN [ -f ${STEAM_LIBS_64}/steamclient.so ] && cp -pr ${STEAM_LIBS_64}/steamclient.so ${VALHEIM_HOME}/linux64/.;

WORKDIR ${STEAM_HOME}
COPY valheim_server.aarch64 ${STEAM_HOME}
COPY valheim_server.update ${STEAM_HOME}
RUN chmod +x ${STEAM_HOME}/valheim_server.aarch64;
RUN chmod +x ${STEAM_HOME}/valheim_server.update;

# cleanup image
WORKDIR /
USER root
RUN rm -rf ${VALHEIM_HOME}/.tmp;
RUN apt-get autoremove --purge -y curl;
RUN rm -rf /var/lib/apt/lists/*;

# ports
EXPOSE ${VALHEIM_PORT}-${VALHEIM_PORT_ASIDE}/tcp
EXPOSE ${VALHEIM_PORT}-${VALHEIM_PORT_ASIDE}/udp

WORKDIR ${STEAM_HOME}
VOLUME [ "${STEAM_HOME}" ]

# user / group
RUN groupadd -g ${STEAM_GROUP_ID} ${STEAM_USER} && \
  useradd -m -u ${STEAM_USER_ID} -g ${STEAM_GROUP_ID} -s /bin/bash ${STEAM_USER} && \
  chown -R ${STEAM_USER}:${STEAM_USER} ${STEAM_HOME};

WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}
RUN ${STEAM_HOME}/steamcmd.update;
RUN mkdir -p ~/Steam ~/.steam && \
  ln -fns "${STEAMCMD_HOME}/sdk32" ~/.steam/. && \
  ln -fns "${STEAMCMD_HOME}/sdk64" ~/.steam/. && \
  ln -fns "${STEAMCMD_HOME}/sdk32" ~/Steam/. && \
  ln -fns "${STEAMCMD_HOME}/sdk64" ~/Steam/.;

WORKDIR ${STEAM_HOME}
USER ${STEAM_USER}

# entrypoint
ENTRYPOINT [ "bash", "/opt/steam/valheim_server.aarch64" ]
