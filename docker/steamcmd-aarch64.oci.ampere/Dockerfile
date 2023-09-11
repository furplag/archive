FROM furplag/box86_64:aarch64.oci.ampere-latest

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Asia/Tokyo

# builder:packages
RUN \
apt-get update && apt-get upgrade && apt-get dist-upgrade -y && \
apt-get install -y curl locales tzdata;

RUN sed -i -E 's/# (en_US.UTF-8)/\1/' /etc/locale.gen && locale-gen;
ENV LANG en_US.UTF-8

# steamcmd
WORKDIR /
RUN mkdir -p /opt/steam/steamcmd;

WORKDIR /opt/steam/steamcmd
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -;
RUN export LD_LIBRARY_PATH=/opt/steam/steamcmd/linux32:$LD_LIBRARY_PATH; export DEBUGGER=`which box86`; /opt/steam/steamcmd/steamcmd.sh +quit || echo "" >/dev/null 2>&1;

RUN ln -fns /opt/steam/steamcmd/linux32 /opt/steam/steamcmd/sdk32 && \
  ln -fns /opt/steam/steamcmd/linux64 /opt/steam/steamcmd/sdk64;

RUN mkdir -p ~/.steam && \
  ln -fns /opt/steam/steamcmd/sdk32 ~/.steam/. && \
  ln -fns /opt/steam/steamcmd/sdk64 ~/.steam/.;

RUN mkdir -p ~/Steam && \
  ln -fns /opt/steam/steamcmd/sdk32 ~/Steam/. && \
  ln -fns /opt/steam/steamcmd/sdk64 ~/Steam/.;

COPY https://github.com/furplag/archive/raw/master/docker/steamcmd-aarch64.oci.ampere/.steamcmd.env /opt/steam
RUN mv /opt/steam/.steamcmd.env /etc/profile.d/steamcmd.sh && chmod 644  /etc/profile.d/steamcmd.sh;

WORKDIR /
USER root
