# Install JDK with "alternatives"

## TL;DR
1. Install Open JDK .
1. Set "alternatives" for JDK .
1. Set $JAVA_HOME ( relate to alternatives config ) .

## Getting start
+ [install OpenJDK 8](install.jdk.8.md) .
+ [install OpenJDK 11](install.jdk.11.md) .
+ [install OpenJDK 16](install.jdk.16.md) .

## Quickstart
by defaults, install [Adaptium Open JDK](https://adoptium.net/) into /opt/java/jdk-xx . 
### el8 or later
> unfortunately, only works on x64 and aarch64, currently . 
```root.terminal.bash
[root@el8+ ~]# curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Java/jdk.binary.install.sh | bash
```
