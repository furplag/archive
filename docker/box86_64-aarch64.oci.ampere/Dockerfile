FROM debian:bookworm-slim as boxes

###
# box86_64-aarch64.oci.ampere/Dockerfile
# https://github.com/furplag/archive/docker
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# a base Dockerfile that enable to use x86_64 application on arm64/v8 instance ( especially for A1.Flex-ampere Linux  ) .
#
# Usage
# A. docker build https://github.com/furplag/archive/raw/master/docker/box86_64-aarch64.oci.ampere/Dockerfile -t furplag/box86_64:latest
# B. docker build https://github.com/furplag/archive/raw/master/docker/box86_64-aarch64.oci.ampere/Dockerfile \
#     --build-arg BOX86_VERSION=v0.3.4 \
#     --build-arg BOX64_VERSION=v0.2.6 \
#     -t furplag/box86_64
#

###
# ENV / variable
###
ARG DEBIAN_FRONTEND="noninteractive"
ARG BOX86_VERSION=
ARG BOX64_VERSION=

###
# process
###

# packages ( to build box86 / 64 )
RUN dpkg --add-architecture armhf && apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y;
RUN apt-get install --no-install-recommends --no-install-suggests -y \
  build-essential ca-certificates cmake curl gcc-arm-linux-gnueabihf git libc6-dev-armhf-cross libc6:armhf libncurses6:armhf libstdc++6:armhf make python3;

# Box86 ( see https://github.com/ptitSeb/box86 )
WORKDIR /opt
USER root
RUN git clone https://github.com/ptitSeb/box86$(if [[ "${BOX86_VERSION:-}" = '' ]];  then echo '' else echo "-b ${BOX86_VERSION}"; fi) && \
  mkdir -p /opt/box86/build;

WORKDIR /opt/box86/build
RUN \
  cmake .. -DARM64=1 -DARM_DYNAREC=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
  make -j$(nproc) && make install DESTDIR=/opt/box;

# Box64 ( see https://github.com/ptitSeb/box64 )
WORKDIR /opt
RUN git clone https://github.com/ptitSeb/box64$(if [[ "${BOX64_VERSION:-}" = '' ]];  then echo '' else echo " -b ${BOX64_VERSION}"; fi) && \
  mkdir -p /opt/box64/build;

WORKDIR /opt/box64/build
RUN \
  cmake .. -DRPI4ARM64=1 -DARM_DYNAREC=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
  make -j$(nproc) && make install DESTDIR=/opt/box;

FROM debian:bookworm-slim
COPY --from=boxes /opt/box /

# packages
RUN dpkg --add-architecture armhf && apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y;
RUN apt-get install -y --install-recommends \
  ca-certificates curl libc6:armhf libncurses5:armhf libstdc++6:armhf;

# cleanup
WORKDIR /
RUN apt-get autoremove --purge -y curl;
RUN apt-get clean autoclean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists;

WORKDIR /root
USER root
