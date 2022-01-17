#!/bin/bash
set -ue -o pipefail
export LC_ALL=C

###
# jdk.binary.install.sh
# https://github.com/furplag/archive/Java
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# install JDK with alternatives .
#
# Overview
# 1. Requirement
#    all commands need you are "root" or you listed in "wheel"
# 2. usage
#    A. curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Java/jdk.binary.install.sh | bash
#    B. curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Java/jdk.binary.install.sh | bash -s -- \
#       https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz
#    C. cat <<_EOT_| bash
#       declare -r basedir=/usr/java
#       source <(curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Java/jdk.binary.install.sh)
#       _EOT_
#    D. jdk.binary.install.sh.# custom configuration for your own .

###
# utilities
#

###
# text conversion to single line string .
# - newline ( '\r', '\n' ) replaces to space .
# - combine consecutive spaces to one space .
# - then returns trimmed text .
#
# returns single-lineared string
function linearize(){ echo -e "${1:-}" | sed -z -e 's/[\r\n]\+//g' -e 's/\s\+/ /g' -e 's/^\s\+\|\s\+$//g'; }

###
# sanitizing url and path .
# - combine consecutive slashes to one .
# - remove trailing slash .
# - relative paths convert to absolute one .
#
# returns sanitized string
function sanitize() {
  local -r _path="$(linearize "${1:-}" | sed -e 's/\s/\//g' -e 's/\/\+/\//g' -e 's/\/$//')"
  echo "$(
    if echo "${_path:-}" | grep -E '^ *$' >/dev/null 2>&1; then echo ''
    elif echo "${_path:-}" | grep -E '^\.' >/dev/null 2>&1; then echo "$(realpath ${_path})"
    else echo "${_path}"; fi
  )"
}

###
# variable
#
# statics
if ! declare -p name >/dev/null 2>&1; then declare -r name='jdk.binary.install'; fi
if ! declare -p basedir >/dev/null 2>&1; then declare -r basedir='/opt/java'; fi
if ! declare -p workdir >/dev/null 2>&1; then declare -r workdir="${basedir}/archive"; fi
if ! declare -p log_dir >/dev/null 2>&1; then declare -r log_dir="${basedir}/logs"; fi
if ! declare -p log >/dev/null 2>&1; then declare -r log="${name}.$(date +"%Y-%m-%d").log"; fi
if ! declare -p configuration_file >/dev/null 2>&1; then declare -r configuration_file="${basedir}/.jdk.binary.install.config"; fi
if ! declare -p config >/dev/null 2>&1; then declare -A config=(
  [name]="${name:-}"
  [basedir]="${basedir:-}"
  [workdir]="${workdir:-}"
  [configuration_file]="${configuration_file:-}"

  [logging]=1
  [log_dir]="${log_dir:-}"
  [log]="${log:-}"
  [log_console]=0
  [debug]=1

  [url]="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.1%2B12/OpenJDK17U-jdk_$(arch | sed -e 's/^x86_/x/')_linux_hotspot_17.0.1_12.tar.gz"
  [maven]=0
  [maven_url]='https://dlcdn.apache.org/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz'

  [set_env]=0
); fi
if ! declare -p log_levels >/dev/null 2>&1; then declare -ar log_levels=(DEBUG INFO WARN ERROR FATAL SUCCESS IGNORE); fi
if ! declare -p log_errors >/dev/null 2>&1; then declare -ar log_errors=(ERROR FATAL); fi
if ! declare -p log_symbols >/dev/null 2>&1; then declare -Ar log_symbols=(
  [DEBUG]='\xF0\x9F\x9A\xA7' # 🚧
  [INFO]='\xF0\x9F\x90\xB5' # 🐵
  [WARN]='\xF0\x9F\x99\x88' # 🙈
  [ERROR]='\xF0\x9F\x99\x89' # 🙉
  [FATAL]='\xF0\x9F\x91\xBA' # 🙊
  [SUCCESS]='\xF0\x9F\x8D\xA3' # 🍣
  [IGNORE]='\xF0\x9F\x8D\xA5' # 🍥
); fi

if ! declare -p result >/dev/null 2>&1; then declare -i result=0; fi

###
# argument
#
# 1: source url
config[url]="$(_1="$(linearize "${1:-}")"; if [[ "${_1}" == '' ]]; then echo "${config[url]}"; else echo "${_1:-}"; fi)"

###
# functions
#

###
# _log: simply logging
#
# usase: _log [level] [message]
# Note: no output any "debug" calls under mod_md processing, even if debug=0 .
function _log(){
  local -r _log_level=$(_1="${1:-none}"; _1="${_1^^}"; echo "${_1// /}")
  local -r _message="${2:-}"

  if [[ $(( ${config[logging]:-0} + ${config[log_console]:-0} )) -gt 1 ]]; then return 0
  elif [[ $(( ${config[debug]:-0} )) -gt 0 ]] && [[ "${_log_level}" = 'DEBUG' ]]; then return 0
  elif [[ ! " ${log_levels[@]} " =~ " ${_log_level} " ]]; then return 0; fi

  local -r _symbol="${log_symbols["${_log_level}"]}"
  local -r _stderr="$(if [[ " ${log_errors[@]} " =~ " ${_log_level} " ]]; then echo ' >&2'; else echo ''; fi)"

  if [[ $(( ${config[logging]:-0} )) -eq 0 ]] && [[ -n "${config[log_dir]}" ]] && [[ -n "${config[log]}" ]]; then
    [[ -d "${config[log_dir]}" ]] || mkdir -p "${config[log_dir]}"
  fi

  local _log="echo -e \"`date +"%Y-%m-%d %H:%M:%S"` - ${_symbol}: ${_message}\""

  if [[ $(( ${config[logging]:-0} + ${config[log_console]:-0} )) -eq 0 ]]; then bash -c "${_log}${_stderr} | tee -a \"${config[log_dir]}/${config[log]}\""
  elif [[ $(( ${config[logging]:-0} )) -ne 0 ]]; then bash -c "${_log}${_stderr}";
  else bash -c "${_log} >>\"${config[log_dir]}/${config[log]:-${log}}\""; fi

  return 0
}

###
# processing
#
# read configuration
if [[ " ${config[@]} " =~ ' initialized ' ]]; then :;
elif ! curl --version >/dev/null 2>&1; then _log FATAL "enable to command \"curl\" first"; result=1
elif ! tee --version >/dev/null 2>&1; then _log FATAL "enable to command \"tee\" first"; result=1
elif [[ ! -f "${config[configuration_file]}" ]]; then _log IGNORE "configuration_file ( \"${config[configuration_file]}\" ) not found"
else
  for readline in $(cat ${config[configuration_file]} | grep -v ^# | grep -vE "^\s*\[.+\]" | grep -E ^.+=.+$ | sed -e 's/^\s\+\|\s\+$//g' | sort -r); do
    config["${readline/=*}"]="${readline/*=}"
  done
fi

for _required in basedir workdir url; do
  [[ "$(echo config[$_required])" = '' ]] && _log ERROR "${_required} must not be empty" && result=1;
done

_log DEBUG "config=(\\n$(for k in ${!config[@]}; do echo "  $k=${config[$k]}"; done)\\n)"

if [[ $(("${result:-1}")) -ne 0 ]]; then exit $((${result:-1}));
else config[initialized]="${0:-${name}}"; fi

declare -r _basedir="$(_path="$(sanitize "${config[basedir]}")"; echo "${_path:-${basedir}}")"
if [[ ! "${_basedir}" = "${config[basedir]}" ]]; then
  _log WARN "malformed JDK install path ( \"${config[basedir]}\" ) fallbacks to \"${_basedir}\" ."
elif [[ ! -d "${_basedir}" ]]; then mkdir -p "${_basedir}"; fi

declare -r _workdir="$(_path="$(sanitize "${config[workdir]}")"; echo "${_path:-${workdir}}")"
if [[ ! "${_workdir}" = "${config[workdir]}" ]]; then
  _log WARN "malformed directory path ( \"${config[workdir]}\" ) fallbacks to \"${_workdir}\" ."
elif [[ ! -d "${_workdir}" ]]; then mkdir -p "${_workdir}"; fi

declare -r _url="$(sanitize "${config[url]}")"
declare -r _source="$(_name="${_url##*/}"; echo "${_name:-`date +"%Y%m%d"`.downloadsource}")"
if echo "${_source}" | grep -E '\.rpm$' >/dev/null 2>&1; then
  _log ERROR "should better use the command below to install from RPM,"
  _log ERROR ''
  _log ERROR "$(if dnf --version >/dev/null 2>&1; then echo 'dnf'; else echo 'yum'; fi) install \\\\"
  _log ERROR "  ${_url}"
  _log ERROR ''
  result=1
fi

_log debug "_basedir=[${_basedir}]"
_log debug "_workdir=[${_workdir}]"
_log debug "_url=[${_url}]"
_log debug "_source=[${_source}]"

if [[ $(("${result:-1}")) -ne 0 ]]; then exit $((${result:-1})); fi

# install JDK
if [[ -f "${_workdir}/${_source}" ]]; then _log IGNORE "JDK binary already exists at \"${_workdir}/${_source}\" ."
elif echo "${_url}" | grep -E '^https?' >/dev/null 2>&1; then _log INFO "downloading JDK binary from \"${_url}\" ..."; curl -fL "${_url}" -o "${_workdir}/${_source}"
elif [[ -f "${_url}" ]]; then _log INFO "copying JDK binary from \"${_url}\" ..."; cp -p "${_url}" "${_workdir}/${_source}"; fi

if [[ ! -f "${_workdir}/${_source}" ]]; then _log ERROR "could not download JDK binary ."; result=1; fi
if [[ $(("${result:-1}")) -ne 0 ]]; then exit $((${result:-1})); fi

declare -r _java_home="$(tar ztf "${_workdir}/${_source}" 2>/dev/null | grep -m 1 -e / | sed -e 's/\/.*$//')"
if [[ "${_java_home}" = '' ]]; then _log ERROR "could not detect JDK home from source \"${_source}\" ."; result=1
elif "${_basedir}/${_java_home}/bin/java" -version >/dev/null 2>&1; then _log IGNORE "JDK already installed at \"${_basedir}/${_java_home}\" ."
elif [[ -d "${_basedir}/${_java_home}" ]]; then _log FATAL "directory \"${_basedir}/${_java_home}\" already exists, but it's not work ."; result=1; fi
if [[ $(("${result:-1}")) -ne 0 ]]; then exit $((${result:-1})); fi

if [[ ! -d "${_basedir}/${_java_home}" ]]; then tar zxf "${_workdir}/${_source}" -C "${_basedir}" >/dev/null 2>&1; fi
if ! "${_basedir}/${_java_home}/bin/java" -version >/dev/null 2>&1; then _log ERROR "java not found ( \"${_basedir}/${_java_home}/bin/java\" ) ."; result=1
else _log INFO "java: \"${_basedir}/${_java_home}/bin/java\" installed ."; fi
if [[ $(("${result:-1}")) -ne 0 ]]; then exit $((${result:-1})); fi

# install Maven
declare _maven_home=
if [[ $((${config[maven]:-1})) -eq 0 ]]; then
  [[ "${JAVA_HOME:-}" ]] || export JAVA_HOME="${_basedir}/${_java_home}"
  declare -r _maven_url="$(sanitize "${config[maven_url]}")"
  if [[ "${_maven_url}" = '' ]]; then :;
  elif [[ "$([[ -d "${_basedir}/maven" ]] || mkdir -p "${_basedir}/maven"; if [[ -d "${_basedir}/maven" ]]; then echo 'y'; else echo ''; fi)" = '' ]]; then
    _log ERROR "could not create directory \"${_basedir}/maven\" ."
    result=1
  else
    declare -r _maven_source="$(_name="${_maven_url##*/}"; echo "${_name:-`date +"%Y%m%d"`.downloadsource}")"
    if echo "${_maven_source}" | grep -E '\.rpm$' >/dev/null 2>&1; then
      _log ERROR "should better use the command below to install Maven from RPM,"
      _log ERROR ''
      _log ERROR "$(if dnf --version >/dev/null 2>&1; then echo 'dnf'; else echo 'yum'; fi) install \\\\"
      _log ERROR "  ${_maven_url}"
      _log ERROR ''
      result=1
    elif [[ -f "${_workdir}/${_maven_source}" ]]; then _log IGNORE "Maven binary already exists at \"${_workdir}/${_maven_source}\" ."
    elif echo "${_maven_url}" | grep -E '^https?' >/dev/null 2>&1; then _log INFO "downloading Maven binary from \"${_maven_url}\" ..."; curl -fL "${_maven_url}" -o "${_workdir}/${_maven_source}"
    elif [[ -f "${_maven_url}" ]]; then _log INFO "copying Maven binary from \"${_maven_url}\" ..."; cp -p "${_maven_url}" "${_workdir}/${_maven_source}"; fi
  fi
  _log debug "_maven_source=[${_workdir}/${_maven_source}]"

  if [[ $(("${result:-1}")) -ne 0 ]]; then :;
  elif [[ ! -f "${_workdir}/${_maven_source}" ]]; then _log ERROR "could not download Maven binary ."; result=1
  else
    declare -r _maven="$(tar ztf "${_workdir}/${_maven_source}" | grep -m 1 -e / | sed -e 's/\/.*$//')";
    if [[ "${_maven}" = '' ]]; then _log ERROR "could not detect Maven home from source \"${_maven_source}\" ."; result=1
    elif "${_basedir}/maven/${_maven}/bin/mvn" -version >/dev/null 2>&1; then _log IGNORE "Maven already installed at \"${_basedir}/maven/${_maven_home}\" ."
    elif [[ -d "${_basedir}/maven/${_maven}" ]]; then _log FATAL "directory \"${_basedir}/maven/${_maven_home}\" already exists, but it's not work ."; result=1; fi

    if [[ $(("${result:-1}")) -ne 0 ]]; then :;
    else tar zxf "${_workdir}/${_maven_source}" -C "${_basedir}/maven" >/dev/null 2>&1; fi

    if [[ $(("${result:-1}")) -ne 0 ]]; then :;
    elif ! "${_basedir}/maven/${_maven}/bin/mvn" -version >/dev/null 2>&1; then _log ERROR "mvn not found ( \"${_basedir}/maven/${_maven}/bin/mvn\" ) ."; result=1
    else _log SUCCESS "Maven: \"${_basedir}/maven/${_maven}/bin/mvn\" installed ."; fi
  fi
  if [[ $(("${result:-1}")) -eq 0 ]]; then _maven_home="${_maven}"; fi
fi
if [[ $(("${result:-1}")) -ne 0 ]]; then exit $((${result:-1})); fi

# generate priority
if [[ $((${config[debug]:-1})) -eq 0 ]]; then
  __v="$(echo "${_java_home}" | sed -e 's/^jdk\-\?//i' -e 's/^1\.//'  -e 's/^.*\([0-9]\+\)u/\1u/' -e 's/^\([0-9]\+\)u\([0-9]\+\)$/\1.\2_00/' -e 's/u/./' -e 's/[\+\-]b\?/_/' -e 's/^\([0-9]\+\)_\([0-9]\+\)$/\1.00_\2/' -e 's/\.\([0-9]\+\)\.\([0-9]\+\)_/.\1\2_/' -e 's/\-.*$//' -e 's/\_\D$/_00/')";
  _log debug "version string: [$__v]"

  _major_version="${__v//.*}"
  _log debug "major version: [$_major_version]"
  _minor_version="$(if echo "${__v}" | grep -E '\.' >/dev/null 2>&1; then echo "${__v//*.}" | sed -e 's/_.*$//'; else echo '00'; fi)"
  _log debug "minor version: [$_minor_version]"
  _build_version="$(if echo "${__v}" | grep _ >/dev/null 2>&1; then echo "${__v//*_}" | sed -e 's/[^0-9]/0/gi'; else echo '00'; fi)"
  _log debug "build version: [$_build_version]"

  _minor_version="$(if [[ $((${_minor_version})) -gt 99 ]]; then echo '99'; else echo $(("${_minor_version##0}")); fi)"
  _log debug "->minor version: [$_minor_version]"
  _build_version="$(if [[ $((${_build_version})) -gt 99 ]]; then echo '99'; else echo $(("${_build_version##0}")); fi)"
  _log debug "->build version: [$_build_version]"
fi

declare -ir _version="$(_v="$(
  __v="$(echo "${_java_home}" | sed -e 's/^jdk\-\?//i' -e 's/^1\.//'  -e 's/^.*\([0-9]\+\)u/\1u/i' -e 's/^\([0-9]\+\)u\([0-9]\+\)$/\1.\2_00/' -e 's/u/./' -e 's/[\+\-]b\?/_/' -e 's/^\([0-9]\+\)_\([0-9]\+\)$/\1.00_\2/' -e 's/\.\([0-9]\+\)\.\([0-9]\+\)_/.\1\2_/' -e 's/\-.*$//' -e 's/\_\D$/_00/')";
  _major_version="${__v//.*}"
  _minor_version="$(if echo "${__v}" | grep -E '\.' >/dev/null 2>&1; then echo "${__v//*.}" | sed -e 's/_.*$//'; else echo '00'; fi)"
  _minor_version="$(if [[ $((${_minor_version})) -gt 99 ]]; then echo '99'; else echo $(("${_minor_version##0}")); fi)"
  _build_version="$(if echo "${__v}" | grep _ >/dev/null 2>&1; then echo "${__v//*_}" | sed -e 's/[^0-9]/0/gi'; else echo '00'; fi)"
  _build_version="$(if [[ $((${_build_version})) -gt 99 ]]; then echo '99'; else echo $(("${_build_version##0}")); fi)"
  echo "$(printf '%02d' "${_major_version:-00}")$(printf '%02d' "${_minor_version:-00}")$(printf '%02d' "${_build_version:-00}")"
)"; echo "${_v##0}")"
_log debug "_version=[${_version}]"

# alternatives for java
declare _alternatives=''
for child in `ls "${_basedir}/${_java_home}/bin" | grep -vE "^java$"`; do
  [[ "${_alternatives:-}" = '' ]] && _alternatives="alternatives --install /usr/bin/java java ${_basedir}/${_java_home}/bin/java ${_version}"
  _alternatives="${_alternatives} --slave /usr/bin/${child} ${child} ${_basedir}/${_java_home}/bin/${child}"
done
if [[ $((${config[maven]:-1})) -eq 0 ]] && [[ -f "${_basedir}/maven/${_maven_home}" ]] && [[ -f "${_basedir}/maven/${_maven_home}" ]]; then
  for child in `ls "${_basedir}/${_java_home}/bin" | grep -vE "^java$"`; do
    [[ "${_alternatives:-}" = '' ]] && _alternatives="alternatives --install /usr/bin/java java ${_basedir}/${_java_home}/bin/java ${_version}"
    _alternatives="${_alternatives} --slave /usr/bin/${child} ${child} ${_basedir}/${_java_home}/bin/${child}"
  done
fi
if [[ -n "${_alternatives}" ]]; then
  if [[ $((${config[maven]:-1})) -eq 0 ]] && [[ -n "${_maven_home}" ]]; then
    for child in mvn mvnDebug; do
      _alternatives="${_alternatives} --slave /usr/bin/${child} ${child} ${_basedir}/maven/${_maven_home}/bin/${child}"
    done
  fi
  bash -c "${_alternatives}"
  if alternatives --display java | grep "${_basedir}/${_java_home}/bin/java" >/dev/null; then _log INFO "alternatives \"java\" successfully installed as \"${_version}\" ."; fi
fi

# environment
if [[ $((${config[set_env]:-1})) -eq 0 ]]; then
  cat <<_EOT_> /etc/profile.d/java.sh
# /etc/profile.d/java.sh

# Set Environment with alternatives for Java VM.
export JAVA_HOME=\$(readlink /etc/alternatives/java | sed -e 's/\/bin\/java//g')

_EOT_

if [[ $((${config[maven]:-1})) -eq 0 ]] && [[ -n "${_maven_home}" ]]; then
    cat <<_EOT_>> /etc/profile.d/java.sh
# Set Environment with alternatives for Maven.
export MAVEN_HOME=\$(readlink /etc/alternatives/mvn | sed -e 's/\/bin\/mvn//g')
export M2_HOME=\${MAVEN_HOME}

_EOT_
  fi
  alternatives --set java "${_basedir}/${_java_home}/bin/java" && source /etc/profile.d/java.sh
else alternatives --set java "${_basedir}/${_java_home}/bin/java"; fi

if [[ "${_basedir}/${_java_home}" = "${JAVA_HOME}" ]]; then
  _log SUCCESS "java \"${_basedir}/${_java_home}\" successfully installed ."
  _log SUCCESS "execute command below to change JDK,"
  _log SUCCESS ''
  _log SUCCESS "alternatives --set java "${_basedir}/${_java_home}/bin/java" && source /etc/profile"
  _log SUCCESS ''
else _log ERROR "failed install \"${_basedir}/${java_home}\" ."; result=1; fi

exit $((${result:-1}))
