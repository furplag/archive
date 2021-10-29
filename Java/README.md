# Install JDK with "alternatives"

## TL;DR
1. Install Open JDK .
1. Set "alternatives" for JDK .
1. Set $JAVA_HOME ( relate to alternatives config ) .

## Getting start
by defaults, install [Adaptium Open JDK](https://adoptium.net/) into /opt/java/jdk-xx . 

### requirement
> unfortunately, only works on x64 and aarch64, currently . 
* [ ] all commands need you are "root" or you listed in "wheel"
* [ ] `curl` enabled ( package: curl )
* [ ] `sed` enabled ( package: sed )
* [ ] `tar` enabled ( package: tar )
* [ ] `tee` enabled ( package: coreutils )

#### using standard
- install [Adoptium JDK 17+35](https://adoptium.net/)
- install [Apache Maven 3.8.3](https://maven.apache.org/)
- set alternatives `java`, some commands in "${JAVA_HOME}/bin/" and `mvn{,Debug}`
- set environments "JAVA_HOME" and "M2_HOME" ( "MAVNE_HOME" )
```root.terminal.bash
[root@el8+ ~]# curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Java/jdk.binary.install.sh | bash
```

#### custom install: JDK
```root.terminal.bash
[root@el8+ ~]# curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Java/jdk.binary.install.sh | bash -s -- \
               > https://download.java.net/openjdk/jdk17/ri/openjdk-17+35_linux-x64_bin.tar.gz
```

#### custom install: JDK install directory
```root.terminal.bash
[root@el8+ ~]# cat <<_EOT_|bash -s -- https://download.oracle.com/java/17/latest/jdk-17_linux-aarch64_bin.tar.gz
declare -r basedir='/usr/local/java'
source <(curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Java/jdk.binary.install.sh)
_EOT_
```
#### custom install: JDK install directory
```root.terminal.bash
[root@el8+ ~]# mkdir -p /opt/java
[root@el8+ ~]# cat <<_EOT_> /opt/java/.jdk.binary.install.config
[logging]=0
[log_console]=0
[debug]=0
[maven]=0
[maven_url]='https://dlcdn.apache.org/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz'
[set_env]=1
_EOT_
[root@el8+ ~]# curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Java/jdk.binary.install.sh | bash
```

and customize configuration [for your own](./jdk.binary.install.sh) .
