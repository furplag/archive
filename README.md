# RHEL, Cent OS

## Using RPM repository

```createrepo.sh
[root@anywhere ~]# cat <<_EOT_> /etc/yum.repos.d/furplag.github.io.repo
[furplag.github.io]
name=https://raw.github.com/furplag/archive
baseurl=https://raw.githubusercontent.com/furplag/archive/rpm/el\$releasever/\$basearch
skip_if_unavailable=1
enabled=0
gpgcheck=1
gpgkey=https://raw.githubusercontent.com/furplag/archive/rpm/RPM-GPG-KEY-furplag.github.io

[furplag.github.io-source]
name=https://raw.github.com/furplag/archive
baseurl=https://raw.githubusercontent.com/furplag/archive/rpm/el\$releasever/SRPMS
skip_if_unavailable=1
enabled=0
gpgcheck=1
gpgkey=https://raw.githubusercontent.com/furplag/archive/rpm/RPM-GPG-KEY-furplag.github.io

_EOT_
```
