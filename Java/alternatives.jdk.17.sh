#!/bin/bash
set -ue -o pipefail
export LC_ALL=C

# alternatives.jdk.17.sh

# variables
if ! declare -p jdk_root >/dev/null 2>&1; then declare -r jdk_root=/opt/java; fi
if ! declare -p source_url >/dev/null 2>&1; then
  declare -r source_url=https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17%2B35/OpenJDK17-jdk_aarch64_linux_hotspot_17_35.tar.gz;
fi
if ! declare -p priority >/dev/null 2>&1; then declare -r priority=17035; fi
# declare -r source="${jdk_root}/$(echo "${source_url}" | sed -e 's@^\.*\/@@')";
if ! declare -p source >/dev/null 2>&1; then declare source='OpenJDK17-jdk_aarch64_linux_hotspot_17_35.tar.gz'; fi
if ! declare -p java_home >/dev/null 2>&1; then declare java_home="${jdk_root}/jdk-17+35"; fi

[ -d "${jdk_root}" ] || mkdir -p "${jdk_root}";
curl -fL "${source_url}" -o "${source}";

[ -e "${source}" ] || exit 1;

tar zxvf "${source}" -C "${jdk_root}";
[ -e "${java_home}" ] || exit 1;

alternatives --remove java "${java_home}/jre/bin/java" >/dev/null 2>&1;
alternatives --remove java "${java_home}/bin/java" >/dev/null 2>&1;

alternatives --install /usr/bin/java java "${java_home}" ${priority} \
--slave /usr/bin/alt-java alt-java "${java_home}/bin/alt-java" \
--slave /usr/bin/keytool keytool "${java_home}/bin/keytool" \
--slave /usr/bin/rmiregistry rmiregistry "${java_home}/bin/rmiregistry";
