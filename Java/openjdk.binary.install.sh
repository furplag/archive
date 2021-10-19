#!/bin/bash
set -ue -o pipefail
export LC_ALL=C

###
# openjdk.binary.install.sh
# https://github.com/furplag/archive/Java/openjdk.binary.install.sh

###
# variable
if declare -p indent >/dev/null 2>&1; then :;
elif declare -p symbols >/dev/null 2>&1; then
 declare indent="${symbols['java']}";
else
  declare -Ar symbols=(
    ["java"]='\xE2\x98\x95'
    ["success"]='\xF0\x9F\x8D\xA3'
    ["error"]='\xF0\x9F\x91\xBA'
    ["fatal"]='\xF0\x9F\x91\xB9'
    ["ignore"]='\xF0\x9F\x8D\xA5'
    ["unspecified"]='\xF0\x9F\x99\x89'
    ["remark"]='\xF0\x9F\x91\xBE'
  )
 declare indent="${symbols['java']}"
fi

if ! declare -p jdk_root >/dev/null 2>&1; then declare -r jdk_root=/opt/java; fi
if ! declare -p source_url >/dev/null 2>&1; then
  echo -e "${indent}${symbols['remark']}: \$source unspecified, using defaults ."
  # see [JDK releases](https://github.com/adoptium/temurin17-binaries/releases/latest/)
  # e.g. ) Linux x64 or aarch64 ( arm64 )
  declare -r source_url="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17%2B35/OpenJDK17-jdk_$(arch | sed -e 's/^x86_/x/')_linux_hotspot_17_35.tar.gz"
fi


alternatives --remove java "${java_home}/jre/bin/java" >/dev/null 2>&1;
alternatives --remove java "${java_home}/bin/java" >/dev/null 2>&1;

alternatives --install /usr/bin/java java "${java_home}" ${priority} \
--slave /usr/bin/alt-java alt-java "${java_home}/bin/alt-java" \
--slave /usr/bin/keytool keytool "${java_home}/bin/keytool" \
--slave /usr/bin/rmiregistry rmiregistry "${java_home}/bin/rmiregistry";

function _prereq() {
  if [[ -n "${jdk_root}" ]] && [[ -n "${source_url}" ]]; then return 0; else echo -e "${indent}${symbols['fatal']}: invalid argument ."; return 1; fi
}

function _install() {
  local -r _source="$(echo $source_url | sed -e 's/^.\*\///'
  [ -d "${jdk_root}" ]  || mkdir -p "${jdk_root}"
  curl -Ls "$(echo "${source_url}" | sed -e 's/\/\([^\/]\+\)$/\/{\1}/')" -o "${jdk_root}/#1"
  local -r _jdk_home="`tar ztf ${_source} 2>/dev/null | grep -m 1 -e /$ | sed -e 's/\///g'`"
  tar zxf "${jdk_root}/${_source}" -C "${jdk_root}" 2>/dev/null

  if `"${jdk_root}/${_jdk_home}/bin/java" -version >/dev/null 2>&1`; then echo "${jdk_root}/${_jdk_home}"; else echo ''; fi
}

#main
[WiP]
