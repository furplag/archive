FROM furplag/box86_64:aarch64.oci.ampere-latest

ENV LANG ja_JP.UTF-8
ENV TZ Asia/Tokyo

ENV STEAM_HOME /opt/steam
ENV STEAMCMD_HOME=${STEAM_HOME}/steamcmd
ENV STEAM_LIBS_86 ${STEAMCMD_HOME}/linux32
ENV STEAM_LIBS_64 ${STEAMCMD_HOME}/linux64
ENV DEBUGGER /usr/local/bin/box86

# packages
RUN \
  apt-get update && apt-get upgrade && apt-get dist-upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y curl locales tzdata;

RUN \
  sed -i -E "s/# (en_US.UTF-8)/\1/" /etc/locale.gen && \
  sed -i -E "s/# (${LANG})/\1/" /etc/locale.gen && \
  locale-gen;

# steamcmd
WORKDIR ${STEAMCMD_HOME}
RUN curl -fsSqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxvf -;

WORKDIR /
RUN \
  tempLdLibPath=${LD_LIBRARY_PATH} && \
  export LD_LIBRARY_PATH=${STEAM_LIBS_86}:${LD_LIBRARY_PATH} && \
  ${STEAMCMD_HOME}/steamcmd.sh +quit || echo '' >/dev/null 2>&1 && \
  export LD_LIBRARY_PATH=${tempLdLibPath};

RUN ln -fns ${STEAM_LIBS_86} ${STEAMCMD_HOME}/sdk32 && ln -fns ${STEAM_LIBS_64} ${STEAMCMD_HOME}/sdk64;
RUN mkdir -p ~/.steam && ln -fns ${STEAMCMD_HOME}/sdk32 ~/.steam/. && ln -fns ${STEAMCMD_HOME}/sdk64 ~/.steam/.;
RUN mkdir -p ~/Steam &&  ln -fns /opt/steam/steamcmd/sdk32 ~/Steam/. && ln -fns /opt/steam/steamcmd/sdk64 ~/Steam/.;

# cleanup
RUN rm -rf "${STEAMCMD_HOME}/.tmp";
RUN apt-get autoremove --purge -y curl;

USER root
