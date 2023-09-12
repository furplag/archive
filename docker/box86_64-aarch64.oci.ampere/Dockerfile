FROM debian:bookworm-slim

# builder:packages
RUN \
  dpkg --add-architecture armhf && \
  apt-get update && apt-get upgrade && apt-get dist-upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y cmake gcc-arm-linux-gnueabihf git make python3 \
  libbz2-1.0:armhf libc6:armhf libfontconfig1:armhf libgl1:armhf libice6:armhf \
  libncurses5:armhf libopenal1:armhf libpng16-16:armhf \
  libsdl2-2.0-0:armhf libsdl2-image-2.0-0:armhf libsdl2-mixer-2.0-0:armhf libsdl2-ttf-2.0-0:armhf \
  libsm6:armhf libxcomposite1:armhf libxdamage1:armhf libxinerama1:armhf libxtst6:armhf libstdc++6:armhf;

ENV BOX86_VERSION v0.3.2
ENV BOX64_VERSION v0.2.4

# box86
RUN echo ${box86-version}
WORKDIR /opt
RUN git clone https://github.com/ptitSeb/box86 -b ${BOX86_VERSION} && mkdir -p /opt/box86/build;

WORKDIR /opt/box86/build
RUN cmake .. -DARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo;
RUN make -j$(nproc);
RUN make install;

# box64
WORKDIR /opt
RUN git clone https://github.com/ptitSeb/box64 -b ${BOX64_VERSION} && mkdir -p /opt/box64/build;

WORKDIR /opt/box64/build
RUN cmake .. -DARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo;
RUN make -j$(nproc);
RUN make install;

# cleanup
WORKDIR /
RUN rm -rf /opt/box86 /opt/box64;

ENV BOX86_VERSION ''
ENV BOX64_VERSION ''

RUN apt-get autoremove --purge -y cmake gcc-arm-linux-gnueabihf git make python3;

USER root
