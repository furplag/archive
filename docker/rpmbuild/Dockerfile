ARG EL_VERSION

FROM oraclelinux:${EL_VERSION}
###
# rpmbuild/Dockerfile
# https://github.com/furplag/archive/docker
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# a disposable workbench to build RPM package .
#

###
# ENV / variable
###
ARG EL_VERSION
ARG LC_ALL
ARG TZ=Etc/UTC
ARG RPMBUILD_GROUP=rpmbuild
ARG RPMBUILD_USER=rpmbuild

ARG RPMBUILD_GROUP_ID
ARG RPMBUILD_USER_ID

ARG REPO_URL
ARG REPO_NAME

ARG GPG_KEY
ARG GPG_PRIVATEKEY
ARG GPG_PRIVATEKEY_PASSPHRASE

###
# process
###

# packages
RUN dnf config-manager --enable ol${EL_VERSION}_{codeready,distro}_builder && \
  if [ -n "${REPO_URL:-}" ] && [ -n "${REPO_NAME:-}" ]; then dnf config-manager --add-repo ${REPO_URL} && dnf config-manager --enable ${REPO_NAME}; fi && \
  dnf clean all && dnf upgrade -y && \
  dnf install -y oracle-epel-release-el${EL_VERSION} && dnf clean all && dnf upgrade -y && \
  dnf group install -y 'Development Tools' 'RPM Development Tools' && \
  dnf install -y createrepo pinentry rpmdevtools sudo && \
  dnf clean all;

# user / group
RUN groupadd -g ${RPMBUILD_GROUP_ID} ${RPMBUILD_GROUP} && \
  useradd -m -r -u ${RPMBUILD_USER_ID} -g ${RPMBUILD_GROUP_ID} -d /home/${RPMBUILD_USER} -s /sbin/nologin ${RPMBUILD_USER} && \
  usermod -aG wheel ${RPMBUILD_USER} && echo '%wheel ALL=NOPASSWD:ALL' >/etc/sudoers.d/999_rpmbuild;

WORKDIR /home/${RPMBUILD_USER}
USER ${RPMBUILD_USER}

# signing key
RUN --mount=type=secret,id=_gpg_key,uid=${RPMBUILD_USER_ID} \
  --mount=type=secret,id=_gpg_privatekey,uid=${RPMBUILD_USER_ID} \
  --mount=type=secret,id=_gpg_privatekey_passphrase,uid=${RPMBUILD_USER_ID} \
  gpg --import --batch /run/secrets/_gpg_key && \
  gpg --import --batch --pinentry-mode loopback --allow-secret-key-import --passphrase-file=/run/secrets/_gpg_privatekey_passphrase /run/secrets/_gpg_privatekey && \
  sudo rpm --import /run/secrets/_gpg_key && \
  rpmdev-setuptree && \
  echo -e "\n%_signature gpg\n%_gpg_name $(gpg --no-tty --no-use-agent --batch -k --with-colons | grep '^fpr:' | cut -d: -f10 | head -n 1)" >>~/.rpmmacros && \
  (gpgconf --kill gpg-agent || true) && \
  find ~/.gnupg -name "*.lock" -delete;

# cleanup
WORKDIR /
USER root
RUN chown -R ${RPMBUILD_USER}:${RPMBUILD_GROUP} /home/${RPMBUILD_USER};
RUN dnf clean all && rm -rf /tmp/*;

VOLUME [ "/home/${RPMBUILD_USER}" ]

WORKDIR /home/${RPMBUILD_USER}
USER ${RPMBUILD_USER}

ENTRYPOINT [ "/bin/bash" ]
