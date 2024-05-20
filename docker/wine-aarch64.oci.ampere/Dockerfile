FROM furplag/box86_64:latest

###
# wine-aarch64.oci.ampere/Dockerfile
# https://github.com/furplag/archive/docker
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# a base Dockerfile that enable to use Wine ( WoW64 ) on arm64/v8 instance ( with Box86 / 64, especially for A1.Flex-ampere.OracleLinux ) .
#
# Usage
# A. docker build https://github.com/furplag/archive/raw/master/docker/wine-aarch64.oci.ampere/Dockerfile -t furplag/wine:latest
# B. docker build https://github.com/furplag/archive/raw/master/docker/wine-aarch64.oci.ampere/Dockerfile \
#     --build-arg WINE_USER=wine \
#     --build-arg WINE_USER_ID=wine \
#     --build-arg WINE_GROUP=wine \
#     --build-arg WINE_GROUP_ID=12002 \
#     --build-arg WINE_USER_HOME=/home/wine \
#     ...
#     -t furplag/wine:latest
#

###
# ENV / variable
###
ARG DEBIAN_FRONTEND='noninteractive'
ARG TZ='Etc/UTC'
ARG LANG='en_US.UTF-8'
ARG LANGUAGE='en_US:en'
ARG LC_ALL='C.UTF-8'

ARG WINE_VERSION='9.3'
ARG WINE_HOME='/opt/wine'
ARG WINE_USER='steam'
ARG WINE_USER_HOME='/opt/steam'
ARG WINE_USER_ID='1201'
ARG WINE_GROUP='steam'
ARG WINE_GROUP_ID='1201'
ARG WINE_PREFIX='~/.wine'

ARG BOX86_NOBANNER='1'
ARG BOX64_NOBANNER='1'

ARG WINE_DEBUG='-all'
ARG WINE_OPT_UNATTENDED='1'

ENV TZ ${TZ}
ENV LANG ${LANG}
ENV LANGUAGE ${LANGUAGE}
ENV LC_ALL ${LC_ALL}

ENV DEBUGGER ${DEBUGGER}
ENV BOX86_NOBANNER ${BOX86_NOBANNER}
ENV BOX64_NOBANNER ${BOX64_NOBANNER}

###
# process
###

WORKDIR /
USER root

# packages
RUN dpkg --add-architecture armhf && apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y;
RUN DEBIAN_FRONTEND=noninteractive TZ=${TZ} apt-get install -y curl gnupg locales sudo tzdata;
RUN locale-gen ${LANG} && dpkg-reconfigure locales;
RUN if [ -f "/usr/share/zoneinfo/${TZ}" ]; then ln -fns /usr/share/zoneinfo/${TZ} /etc/localtime; dpkg-reconfigure --frontend noninteractive tzdata; fi;
RUN apt-get install -y cabextract xz-utils;

# install wine
RUN mkdir -p ${WINE_HOME}/_versions ${WINE_HOME}/.tmp;
RUN curl -fL https://github.com/Pi-Apps-Coders/files/releases/download/large-files/wine-${WINE_VERSION}.tar.gz -o ${WINE_HOME}/.tmp/wine-${WINE_VERSION}.tar.gz;
RUN tar xvf ${WINE_HOME}/.tmp/wine-${WINE_VERSION}.tar.gz -C ${WINE_HOME}/_versions;
RUN mkdir -p ${WINE_HOME}/_versions/wine-${WINE_VERSION}/share/wine/gecko ${WINE_HOME}/_versions/wine-${WINE_VERSION}/share/wine/mono;
RUN curl -fL https://dl.winehq.org/wine/wine-mono/9.0.0/{wine-mono-9.0.0-x86.tar.xz} -o ${WINE_HOME}/.tmp/#1;
RUN tar xvf ${WINE_HOME}/.tmp/wine-mono-9.0.0-x86.tar.xz -C ${WINE_HOME}/_versions/wine-${WINE_VERSION}/share/wine/mono;
RUN curl -fL https://dl.winehq.org/wine/wine-gecko/2.47.4/{wine-gecko-2.47.4-x86_64.tar.xz} -o ${WINE_HOME}/.tmp/#1;
RUN tar xvf ${WINE_HOME}/.tmp/wine-gecko-2.47.4-x86_64.tar.xz -C ${WINE_HOME}/_versions/wine-${WINE_VERSION}/share/wine/gecko;
RUN curl -fL https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -o ${WINE_HOME}/_versions/wine-${WINE_VERSION}/bin/winetricks && \
  chmod +x ${WINE_HOME}/_versions/wine-${WINE_VERSION}/bin/winetricks;
RUN ln -fns ${WINE_HOME}/_versions/wine-${WINE_VERSION}/* ${WINE_HOME}/.;

RUN echo '#!/bin/bash' >/usr/local/bin/wine;
RUN echo "WINEPREFIX=${WINE_PREFIX}" WINEDEBUG=${WINE_DEBUG} W_OPT_UNATTENDED=${WINE_OPT_UNATTENDED} "/usr/local/bin/box64 /opt/wine/bin/wine" '"$@"'  >>/usr/local/bin/wine;
RUN chmod +x /usr/local/bin/wine;

RUN echo '#!/bin/bash' >/usr/local/bin/wineserver;
RUN echo "WINEPREFIX=${WINE_PREFIX}" WINEDEBUG=${WINE_DEBUG} W_OPT_UNATTENDED=${WINE_OPT_UNATTENDED} "/usr/local/bin/box64 /opt/wine/bin/wineserver" '"$@"'  >>/usr/local/bin/wineserver;
RUN chmod +x /usr/local/bin/wineserver;

RUN ln -fns /opt/wine/bin/wineboot /usr/local/bin/wineboot;
RUN ln -fns /opt/wine/bin/winecfg /usr/local/bin/winecfg;
RUN ln -fns /opt/wine/bin/winetricks /usr/local/bin/winetricks;

# user / group
RUN mkdir -p ${WINE_USER_HOME};
RUN groupadd -g ${WINE_GROUP_ID} ${WINE_GROUP} && useradd -m -u ${WINE_USER_ID} -g ${WINE_GROUP_ID} -d ${WINE_USER_HOME} -s /bin/bash ${WINE_USER} && usermod -aG sudo ${WINE_USER};
RUN echo '%sudo ALL=NOPASSWD:ALL' >/etc/sudoers.d/999_${WINE_USER};
RUN chown ${WINE_USER}:${WINE_USER} ${WINE_USER_HOME};

WORKDIR ${WINE_USER_HOME}
USER ${WINE_USER}
RUN wine wineboot;

# cleanup
WORKDIR /
USER root
RUN apt-get autoremove -y;
RUN apt-get clean autoclean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists ${WINE_HOME}/.tmp;

WORKDIR ${WINE_USER_HOME}
USER ${WINE_USER}
