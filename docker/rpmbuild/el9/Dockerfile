FROM oraclelinux:9
###
# rpmbuild/el9/Dockerfile
# https://github.com/furplag/archive/docker
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# workspace to build RPM package .
#
# Requirement
# [ ] a pair of GPG key to signing .
# [ ] a Docker Volume to persists packages built ( recommends to use docker compose ) .
#
# Usage
# A. docker compose up -d
#

###
# ENV / variable
###

ARG LC_ALL
ARG TZ=UTC
ARG RPMBUILD_GROUP=rpmbuild
ARG RPMBUILD_USER=rpmbuild

ARG RPMBUILD_GROUP_ID
ARG RPMBUILD_USER_ID

ARG GPG_KEY
ARG GPG_KEY_ID
ARG GPG_PRIVATEKEY
ARG GPG_PRIVATEKEY_PASSPHRASE

###
# process
###

# packages
RUN dnf config-manager --enable ol9_{codeready,distro}_builder;
RUN [ ! "${REPO_URL:-}" = '' ] && [ ! "${REPO_NAME:-}" = '' ] && dnf config-manager --add-repo ${REPO_URL} && dnf config-manager --enable ${REPO_NAME};
RUN dnf clean all && dnf upgrade -y;
RUN dnf install -y oracle-epel-release-el9;
RUN dnf clean all && dnf upgrade -y;
RUN dnf group install -y 'Development Tools' 'RPM Development Tools';
RUN dnf install -y createrepo pinentry rpmdevtools sudo;

# user / group
RUN groupadd -g ${RPMBUILD_GROUP_ID} ${RPMBUILD_GROUP}
RUN useradd -m -u ${RPMBUILD_USER_ID} -g ${RPMBUILD_GROUP_ID} -s /bin/bash ${RPMBUILD_USER} && \
  usermod -aG wheel ${RPMBUILD_USER}
RUN echo '%wheel ALL=NOPASSWD:ALL' >/etc/sudoers.d/999_rpmbuild

COPY ${GPG_KEY} /home/${RPMBUILD_USER}/
COPY ${GPG_PRIVATEKEY} /home/${RPMBUILD_USER}/

WORKDIR /home/${RPMBUILD_USER}
USER ${RPMBUILD_USER}
RUN gpg --import ~/${GPG_KEY}
RUN gpg --import --allow-secret-key-import --batch --passphrase=${GPG_PRIVATEKEY_PASSPHRASE} ~/${GPG_PRIVATEKEY}
RUN sudo rpm --import ~/${GPG_KEY}
RUN rpmdev-setuptree;

RUN echo -e "\n\
%_signature gpg\n\
%_gpg_name @_@GPG_KEY_ID@_@\n" >>~/.rpmmacros && \
  __gpg_name="$(gpg -k | grep ${GPG_KEY_ID} | sed -e 's/^\s\+//g' -e 's/^.*\///g' -e 's/\s.*$//g')" && \
  sed -i -e "s/@_@GPG_KEY_ID@_@/${__gpg_name}/" ~/.rpmmacros;

# Cleanup
WORKDIR /
USER root
RUN dnf clean all;

# Volume
VOLUME [ "/home/${RPMBUILD_USER}" ]

WORKDIR /home/${RPMBUILD_USER}
USER ${RPMBUILD_USER}

# entrypoint
ENTRYPOINT [ "/bin/bash" ]
