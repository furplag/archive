FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND noninteractive

# builder:packages
RUN \
dpkg --add-architecture armhf && \
apt-get update && apt-get upgrade && apt-get dist-upgrade -y && \
apt-get install -y cmake gcc-arm-linux-gnueabihf git make python3 && \
apt-get install -y libc6:armhf libncurses5:armhf libstdc++6:armhf;

# box86
WORKDIR /opt
RUN git clone https://github.com/ptitSeb/box86 -b "v0.3.2" && mkdir -p /opt/box86/build;

WORKDIR /opt/box86/build
RUN cmake .. -DARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo;
RUN make -j$(nproc);
RUN make install;

# box64
WORKDIR /opt
RUN git clone https://github.com/ptitSeb/box64 -b "v0.2.4" && mkdir -p /opt/box64/build;

WORKDIR /opt/box64/build
RUN cmake .. -DARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo;
RUN make -j$(nproc);
RUN make install;

# cleanup
RUN rm -rf /opt/box86 /opt/box64;
RUN apt-get autoremove --purge -y cmake gcc-arm-linux-gnueabihf git make python3;

WORKDIR /
USER root
