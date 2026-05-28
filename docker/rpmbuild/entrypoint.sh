#!/bin/bash
set -o pipefail
LC_ALL=C.UTF-8

###
# rpmbuild/entrypoint.sh
# https://github.com/furplag/archive/docker
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# cleanup gpg agent cache with starting .
#
(gpgconf --kill gpg-agent || true) && find ~/.gnupg -name "*.lock" -delete;

exec "$@"
