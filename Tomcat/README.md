# Install Apache Tomcat with systemd

## TL;DR
1. Install Tomcat .
1. Set "systemctl" for Tomcat .

## Getting start

### requirement
> unfortunately, only works on x64 and aarch64, currently .
* [ ] all commands need you are "root" or you listed in "wheel"
* [ ] `curl` enabled ( package: curl )
* [ ] `sed` enabled ( package: sed )
* [ ] `tar` enabled ( package: tar )
* [ ] `tee` enabled ( package: coreutils )
* [ ] env JAVA_HOME enabled ( 1.8 or later )

#### using standard
- install [Apache Tomcat v10.0.14](https://tomcat.apache.org/whichversion.html)
```root.terminal.bash
[root@el8+ ~]# curl -fLsS https://github.com/furplag/archive/raw/master/Tomcat/tomcat.binary.install.sh | bash
```

#### custom install
```root.terminal.bash
[root@el8+ ~]# curl -fLsS https://github.com/furplag/archive/raw/master/Tomcat/tomcat.binary.install.sh | bash -s -- \
               > https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.14/bin/apache-tomcat-10.0.14.tar.gz
```

#### custom install: install directory
```root.terminal.bash
[root@el8+ ~]# cat <<_EOT_|bash -s -- https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.14/bin/apache-tomcat-10.0.14.tar.gz
declare -r basedir='/usr/local/src/tomcat10'
source <(curl -fLsS https://github.com/furplag/archive/raw/master/Tomcat/tomcat.binary.install.sh)
_EOT_
```
#### custom install: configuration
```root.terminal.bash
[root@el8+ ~]# mkdir -p /opt/java
[root@el8+ ~]# cat <<_EOT_> /opt/java/.tomcat.binary.install.config
[xms]=512M
[xmx]=4G

[shutdown_port]=18005
[connector_port]=18080
[connector_port_ajp]=18009
[connector_port_redirect]=18443
[connector_port_ssl]=18443
[connector_port_ajp_accept_ip]=0.0.0.0
[connector_port_ajp_secret]=s3cret
[connector_port_ajp_secret_required]=true
_EOT_
[root@el8+ ~]# curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Java/jdk.binary.install.sh | bash
```

and customize configuration [for your own](./tomcat.binary.install.sh) .
