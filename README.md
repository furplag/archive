# RHEL, CentOS

## Using RPM repository

### install repository .
```add.repo.sh
# DNF
[root@gte el8]# dnf config-manager --add-repo https://github.com/furplag/archive/raw/rpm/furplag.github.io.el8.repo

# YUM
[root@lte el6]# yum config-manager --add-repo https://github.com/furplag/archive/raw/rpm/furplag.github.io.[el6/el7/el8].repo
```

or, 

```create.repo.sh
[root@anywhere ~]# cat <<_EOT_> /etc/yum.repos.d/furplag.github.io.repo
[furplag.github.io]
name=https://github.com/furplag/archive/rpm
baseurl=https://raw.githubusercontent.com/furplag/archive/rpm/el\$releasever/\$basearch
skip_if_unavailable=1
enabled=0
gpgcheck=1
gpgkey=https://raw.githubusercontent.com/furplag/archive/rpm/RPM-GPG-KEY-furplag.github.io

[furplag.github.io-source]
name=https://github.com/furplag/archive/rpm
baseurl=https://raw.githubusercontent.com/furplag/archive/rpm/el\$releasever/SRPMS
skip_if_unavailable=1
enabled=0
gpgcheck=1
gpgkey=https://raw.githubusercontent.com/furplag/archive/rpm/RPM-GPG-KEY-furplag.github.io

_EOT_
```

### install packages .
```using.repo.sh
# DNF
[root@gte el8]# dnf install [ package name (s) ] --disablerepo=AppStream --enablerepo=furplag.github.io

# YUM
[root@gte el8]# yum install [ package name (s) ] --enablerepo=furplag.github.io
```
