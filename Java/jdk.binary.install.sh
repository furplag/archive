#!/bin/bash
set -ue -o pipefail
export LC_ALL=C

###
# jdk.binary.install.sh
# https://github.com/furplag/archive/Java
# 
# Licensed under CC0 1.0 (https://creativecommons.org/publicdomain/zero/1.0/deed)
#
# install JDK with alternatives .
#
# Overview
# 1. Requirement
#      all commands need you are "root" or you listed in "wheel"
# 2. parameter (declare before execute, using defaults if undefined )
#      jdk_root: path to install JDK ( default: /opt/java ) .
#      source_url: using latest LTS JDK in Adoptium to default .
# 3. usage
#    A. cat ./jdk.binary.install.sh | bash
#    B. curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Java/jdk.binary.install.sh | bash
#    C. cat <<_EOT_| bash
#       declare -r jdk_root=/usr/local/java
#       declare -r source_url=https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.12%2B7/OpenJDK11U-jdk_x64_linux_hotspot_11.0.12_7.tar.gz'
#       
#       source <(curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Java/jdk.binary.install.sh)
#       _EOT_

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
declare -r source="$(echo $source_url | sed -e 's/^.*\///')"
declare -r version=$(echo "${source}" | sed -e 's/\.[a-z\.]*$//gi' -e 's/^.*_hotspot_//')
declare priority="$(echo "${version}" | sed -e 's/\..*$//' -e 's/_.*$//')"
priority="${priority}$(printf '%02d' "$(if `echo "${version}" | grep -E "\." >/dev/null 2>&1`; then echo "$(echo "${version}" | sed -e 's/^[0-9]*\.//' -e 's/_.*$//' | sed -e 's/[^0-9]//gi')"; else echo '00'; fi)")"
priority="${priority}$(printf '%02d' "$(echo "${version}" | sed -e 's/^[^_]*_\(.*\)$/\1/' -e 's/[^0-9]//gi')")"

function _prereq() {
  local -i _result=0
  if [[ $((${priority})) -lt 1 ]]; then
  _result=1
    echo -e "${indent}${symbols['fatal']}: invalid argument ."
cat <<_EOT_
${indent}${symbols['error']}: source_url="${source_url:-nope}"
${indent}${symbols['error']}: source="${source:-nope}"
${indent}${symbols['error']}: version="${version:-nope}"
${indent}${symbols['error']}: priority="${priority:-0}"
_EOT_
  else echo -e "${indent}${symbols['ignore']}: install JDK ( ${version} ) from \"${source_url}\" to \"${jdk_root}\" ."; fi

  return $_result;
}

function _install() {
  [ -e "${jdk_root}/${source}" ] || curl -Ls "$(echo "${source_url}" | sed -e 's/\/\([^\/]\+\)$/\/{\1}/')" -o "${jdk_root}/#1"
  if [[ -e "${jdk_root}/${source}" ]]; then
    local -r _jdk_home="`tar ztf ${source} 2>/dev/null | grep -m 1 -e /$ | sed -e 's/\///g'`"
    tar zxvf "${jdk_root}/${source}" -C "${jdk_root}"
[ "${jdk_root}/${_jdk_home}" ]
    rm -rf
    if `"${jdk_root}/${_jdk_home}/bin/java" -version >/dev/null 2>&1`; then
      echo "${jdk_root}/${_jdk_home}"
    else echo ''; fi
  else echo ''; fi
}

function _alternatives() {
  local -i _result=1
  local -r _java_home="${1:-}"
  local _alternatives=
  if [[ -n "${_java_home:-}" ]] && [[ -e "${_java_home:-}/bin/java" ]]; then
    for child in `ls "${_java_home:-}/bin" | grep -vE "^java$"`; do
    [ "${_alternatives:-}" = '' ] && _alternatives="alternatives --install /usr/bin/java java ${_java_home}/bin/java ${priority} "
    _alternatives="${_alternatives} --slave /usr/bin/${child} ${child} ${_java_home}/bin/${child}"
  fi

  if [[ "${_alternatives:-}" = '' ]]; then :;
  else
  bash -c "${_alternatives}"
    _result=$?
  fi

  [ "${_result:-1}" = '0' ] || echo -e "${indent}${symbols['fatal']}: could not install alternatives fo ${_java_home}/bin/java ."
  return ${_result:-0}
}

if ! _prereq; then exit 1; fi
declare -r installed_jdk="$(_install)";
if [[ -z "${installed_jdk:-}" ]]; then echo -e "${indent}${symbols['fatal']}: could not install JDK ( ${version} ) from \"${source_url}\" to \"${jdk_root}\" ."; exit 1; fi
if ! `_alternatives  "${installed_jdk}"`; then echo -e "${indent}${symbols['fatal']}: could not install JDK ( ${version} ) from \"${source_url}\" to \"${jdk_root}\" ."; exit 1; fi
