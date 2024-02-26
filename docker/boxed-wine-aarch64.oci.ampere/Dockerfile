FROM debian:bookworm-slim

###
# boxed-wine-aarch64.oci.ampere/Dockerfile
# https://github.com/furplag/archive/docker
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# a base Dockerfile that enable to use Windows application run with Wine on arm64/v8 instance ( especially for A1.Flex-ampere Linux  ) .
#
# Usage
# A. docker build https://github.com/furplag/archive/raw/master/docker/boxed-wine-aarch64.oci.ampere/Dockerfile -t furplag/boxed_wine:latest
# B. docker build https://github.com/furplag/archive/raw/master/docker/boxed-wine-aarch64.oci.ampere/Dockerfile \
#     --build-arg WINE_BRANCH=stable \
#     --build-arg WINE_VERSION=7.0.2 \
#     --build-arg WINE_RELEASE=1 \
#     -t furplag/boxed_wine:stable-7.0.2~bookworm-1
#

###
# ENV / variable
###
ARG DEBIAN_FRONTEND="noninteractive"
ARG WINE_BRANCH="stable"
ARG WINE_VERSION="7.0.2"
ARG WINE_RELEASE="1"
ARG WINEDLLOVERRIDES="mscoree,mshtml="
ARG WINEDEBUG="-all"
ARG W_OPT_UNATTENDED="1"

ARG BOX86_NOBANNER="1"
ARG BOX64_NOBANNER="1"

ENV WINEDLLOVERRIDES ${WINEDLLOVERRIDES}
ENV W_OPT_UNATTENDED ${W_OPT_UNATTENDED}
ENV WINEDEBUG ${WINEDEBUG}
ENV BOX86_NOBANNER ${BOX86_NOBANNER}
ENV BOX64_NOBANNER ${BOX64_NOBANNER}

###
# process
###

# packages ( to build box86 / 64 )
RUN dpkg --add-architecture armhf && apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y;
RUN apt-get install -y curl gnupg;

# add Box86 / 64 repositories
RUN curl -fL https://ryanfortner.github.io/box64-debs/{box64.list} -o /etc/apt/sources.list.d/#1;
RUN curl -fL https://ryanfortner.github.io/box86-debs/{box86.list} -o /etc/apt/sources.list.d/#1;
RUN curl -fLsS https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
RUN curl -fLsS https://ryanfortner.github.io/box86-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg

# install Box86 / 64 with dependencies
RUN apt-get update && apt-get install --install-recommends -y \
  ca-certificates gcc-arm-linux-gnueabihf libc6-dev-armhf-cross libc6:armhf libncurses6:armhf libstdc++6:armhf \
  box86-generic-arm box64-rpi4arm64;

# install Wine
RUN curl -fLsS https://github.com/furplag/archive/raw/master/docker/boxed-wine-aarch64.oci.ampere/wine.install \
  | WINE_BRANCH="${WINE_BRANCH}" WINE_VERSION="${WINE_VERSION}" WINE_RELEASE="${WINE_RELEASE}" \
  WINEDLLOVERRIDES="${WINEDLLOVERRIDES}" W_OPT_UNATTENDED="${W_OPT_UNATTENDED}" WINEDEBUG="${WINEDEBUG}" \
  BOX86_NOBANNER="${BOX86_NOBANNER}" BOX64_NOBANNER="${BOX64_NOBANNER}" bash;

# cleanup
WORKDIR /
RUN apt-get autoremove -y;
RUN apt-get clean autoclean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists;

WORKDIR /root
USER root
