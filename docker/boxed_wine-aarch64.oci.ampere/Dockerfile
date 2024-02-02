FROM furplag/box86_64:latest

###
# boxed_wine-aarch64.oci.ampere/Dockerfile
# https://github.com/furplag/archive/docker
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# a base Dockerfile that enable to use Windows application run with Wine on arm64/v8 instance ( especially for A1.Flex-ampere Linux  ) .
#
# Usage
# A. docker build https://github.com/furplag/archive/raw/master/docker/boxed_wine-aarch64.oci.ampere/Dockerfile -t furplag/boxed_wine:latest
# B. docker build https://github.com/furplag/archive/raw/master/docker/boxed_wine-aarch64.oci.ampere/Dockerfile \
#     --build-arg WINE_BRANCH=staging \
#     --build-arg WINE_VERSION=9.1 \
#     -t furplag/boxed_wine
#

###
# ENV / variable
###
ARG DEBIAN_FRONTEND="noninteractive"
ARG WINE_BRANCH="staging"
ARG WINE_VERSION="9.1"
ARG WINE_RELEASE="1"

RUN dpkg --add-architecture armhf;
RUN apt-get update && apt-get upgrade && apt-get dist-upgrade -y;
RUN apt-get install -y curl;
RUN curl -fLsS https://github.com/furplag/archive/raw/master/docker/boxed_wine-aarch64.oci.ampere/wine.install \
  | WINE_BRANCH="${WINE_BRANCH}" WINE_VERSION="${WINE_VERSION}" WINE_RELEASE="${WINE_RELEASE}" bash;

# cleanup
WORKDIR /
RUN apt-get autoremove --purge -y curl;
RUN apt-get clean autoclean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists;

WORKDIR /root
USER root
