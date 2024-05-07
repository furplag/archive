#!/bin/bash
set -ue -o pipefail
export LC_ALL=C

###
# tomcat.binary.install.sh
# https://github.com/furplag/archive/Tomcat
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# install Tomcat web server .
#
# Overview
# 1. Requirement
#    1. all commands need you are "root" or you listed in "wheel"
#    2. environment named "JAVA_HOME" as a path to JDK
#    3. dependency packages to build Tomcat native: apr-devel, automake, gcc, openssl-devel, redhat-rpm-config
# 2. usage
#    A. curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Tomcat/tomcat.binary.install.sh | bash
#    B. curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Tomcat/tomcat.binary.install.sh | bash -s -- \
#       https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.56/bin/apache-tomcat-9.0.56.tar.gz
#    C. cat <<_EOT_| bash
#       declare -r basedir=/usr/local/src/tomcat
#       source <(curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Tomcat/tomcat.binary.install.sh)
#       _EOT_
#    D. curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Tomcat/tomcat.binary.install.sh && \
#       chmod +x ./tomcat.binary.install.sh && \
#       ./tomcat.binary.install.sh # custom configuration for your own .
#    E. cat <<_EOT_| sudo -E bash -s -- https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.86/bin/apache-tomcat-8.5.86.tar.gz
#       source <(curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/Tomcat/tomcat.binary.install.sh)
#       _EOT_

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
  local -r _path="$(linearize "${1:-}" | sed -e 's/\s/\//g' -e 's/^\/\+/\//' -e 's@\([^:]\)/\{2,\}@\1/@g' -e 's/\/$//')"
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
if ! declare -p packagemanager >/dev/null 2>&1; then declare -r packagemanager="$(if dnf --version >/dev/null 2>&1; then echo 'dnf'; else echo 'yum'; fi)"; fi
if ! declare -p name >/dev/null 2>&1; then declare -r name='tomcat.install'; fi
if ! declare -p basedir >/dev/null 2>&1; then declare -r basedir="/opt/${name}"; fi
if ! declare -p imagedir >/dev/null 2>&1; then declare -r imagedir="${basedir}/_images"; fi
if ! declare -p installdir >/dev/null 2>&1; then declare -r installdir="/usr/share/tomcat"; fi
if ! declare -p log_dir >/dev/null 2>&1; then declare -r log_dir="${basedir}/_logs"; fi
declare -r stamp="$(date +"%Y-%m-%d")";
if ! declare -p log >/dev/null 2>&1; then declare -r log="${name}.${stamp}.log"; fi
if ! declare -p configuration_file >/dev/null 2>&1; then declare -r configuration_file="${basedir}/.${name}.config"; fi
if ! declare -p config >/dev/null 2>&1; then declare -A config=(
  [name]="${name:-}"
  [basedir]="${basedir:-}"
  [imagedir]="${imagedir:-}"
  [installdir]="${installdir:-}"
  [configuration_file]="${configuration_file:-}"

  [logging]=1
  [log_dir]="${log_dir:-}"
  [log]="${log:-}"
  [log_console]=0
  [debug]=1

  [group]='tomcat'
  [user]='tomcat'
  [group_id]=53
  [user_id]=53

  [url]='https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.10/bin/apache-tomcat-10.1.10.tar.gz'
  [url_tcnative]='https://archive.apache.org/dist/tomcat/tomcat-connectors/native/2.0.4/source/tomcat-native-2.0.4-src.tar.gz'
  [url_tcnative12]='https://archive.apache.org/dist/tomcat/tomcat-connectors/native/1.2.37/source/tomcat-native-1.2.37-src.tar.gz'
  [manager]=
  [manager_pw]=
  [xms]=256M
  [xmx]=2G

  [shutdown_port]=8005
  [connector_port]=8080
  [connector_port_ajp]=8009
  [connector_port_redirect]=8443
  [connector_port_ssl]=8443
  [connector_port_ajp_accept_ip]=
  [connector_port_ajp_secret]=
  [connector_port_ajp_secret_required]=1

); fi
if ! declare -p log_levels >/dev/null 2>&1; then declare -ar log_levels=(DEBUG INFO WARN ERROR FATAL SUCCESS IGNORE); fi
if ! declare -p log_errors >/dev/null 2>&1; then declare -ar log_errors=(ERROR FATAL); fi
if ! declare -p log_symbols >/dev/null 2>&1; then declare -Ar log_symbols=(
  [DEBUG]='\xF0\x9F\x9A\xA7' # 🚧
  [INFO]='\xF0\x9F\x90\xB5' # 🐵
  [WARN]='\xF0\x9F\x99\x88' #
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
elif ! tar --version >/dev/null 2>&1; then _log FATAL "enable to command \"tar\" first"; result=1
elif ! tee --version >/dev/null 2>&1; then _log FATAL "enable to command \"tee\" first"; result=1
elif ! ${JAVA_HOME}/bin/java -version >/dev/null 2>&1; then _log FATAL "install JDK first"; result=1
elif [[ ! -f "${config[configuration_file]}" ]]; then _log IGNORE "configuration_file ( \"${config[configuration_file]}\" ) not found"
else
  for readline in $(cat ${config[configuration_file]} | grep -v ^# | grep -vE "^\s*\[.+\]" | grep -E ^.+=.+$ | sed -e 's/^\s\+\|\s\+$//g' | sort -r); do
    config["${readline/=*}"]="${readline/*=}"
  done
  config[source]="$(echo "${config[source]:-}" | sed -e 's/^//')"
fi

for _required in name basedir imgaedir url; do
  [[ "$(echo config[$_required])" = '' ]] && _log ERROR "${_required} must not be empty" && result=1
done

_log DEBUG "config=(\\n$(for k in ${!config[@]}; do echo "  $k=${config[$k]}"; done)\\n)"

if [[ ! "${result:-1}" = '0' ]]; then exit $((${result:-1}));
else config[initialized]="${0:-${name}}"; fi

declare -r _basedir="$(_path="$(sanitize "${config[basedir]}")"; echo "${_path:-${basedir}}")"
if [[ ! "${_basedir}" = "${config[basedir]}" ]]; then _log WARN "malformed install path ( \"${config[basedir]}\" ) fallbacks to \"${_basedir}\" ."; fi
if [[ ! -d "${_basedir}" ]]; then mkdir -p "${_basedir}"; fi

declare -r _imagedir="$(_path="$(sanitize "${config[imagedir]}")"; echo "${_path:-${imagedir}}")"
if [[ ! "${_imagedir}" = "${config[imagedir]}" ]]; then _log WARN "malformed directory path ( \"${config[imagedir]}\" ) fallbacks to \"${_imagedir}\" ."; fi
if [[ ! -d "${_imagedir}" ]]; then mkdir -p "${_imagedir}"; fi

declare -r _workdir="${_basedir}/$(_path="$(sanitize "${config[name]}")"; echo "${_path:-${name}}").${stamp}"
[[ ! "${_workdir:-}" = '' ]] && [[ -d "${_workdir}" ]] && rm -rf "${_workdir}"
[[ ! "${_workdir:-}" = '' ]] && [[ ! -d "${_workdir}" ]] && mkdir -p "${_workdir}"

declare -r _url="$(sanitize "${config[url]}")"
declare -r _source="$(_name="${_url##*/}"; echo "${_name:-`date +"%Y%m%d"`.downloadsource}")"
if [[ "${_source}" = '' ]]; then _log ERROR "could not detect source from url \"${_url}\" ."; result=1
elif echo "${_source}" | grep -E '\.rpm$' >/dev/null 2>&1; then
  _log ERROR "should better use the command below to install from RPM,"
  _log ERROR ''
  _log ERROR "${packagemanager:-dnf} install \\\\"
  _log ERROR "  ${_url}"
  _log ERROR ''
  result=1
fi
if [[ ! "${result:-1}" = '0' ]]; then exit $((${result:-1})); fi

declare -r _version="$(echo "${_source}" | sed -e 's/^.*\-//' -e 's/\.tar\.gz$//')"
declare -r _ver="$(echo "${_version}" | sed -e 's/\..*$//')"
declare -r _home="$(_path="$(sanitize "${config[installdir]}")"; echo "${_path:-${installdir}}")${_ver:-}"
if [[ -d "${_home}" ]]; then
  _log WARN "\"${_home}\" already exists ."
  _timestamp=$(date +"%Y%m%d%H%M%S")
  if mv "${_home}" "${_home}.saved.${_timestamp}"; then _log INFO "moved previous to \"${_home}.saved.${_timestamp}\" ."
  else result=1; fi
fi

_log debug "_basedir=[${_basedir}]"
_log debug "_imagedir=[${_imagedir}]"
_log debug "_workdir=[${_workdir}]"
_log debug "_url=[${_url}]"
_log debug "_source=[${_source}]"
_log debug "_version=[${_version}]"
_log debug "_home=[${_home}]"

if [[ ! "${result:-1}" = '0' ]]; then exit $((${result:-1})); fi

if [[ ! -d "${_basedir}" ]]; then _log ERROR "could not create directory \"${_basedir}\" ."; result=1
elif [[ ! -d "${_imagedir}" ]]; then _log ERROR "could not create directory \"${_imagedir}\" ."; result=1
elif [[ ! -d "${_workdir}" ]]; then _log ERROR "could not create directory \"${_workdir}\" ."; result=1
else
  # create user
  declare -r _group="$(_name="$(sanitize "${config[group]}")"; echo "${_name:-tomcat}")"
  declare -r _user="$(_name="$(sanitize "${config[user]}")"; echo "${_name:-tomcat}")"
  declare -r _gid="$(_name="$(sanitize "${config[group_id]}")"; echo "${_name:-53}")"
  declare -r _uid="$(_name="$(sanitize "${config[user_id]}")"; echo "${_name:-53}")"
  if [[ ! "${_group}:${_user}" = "${config[group]}:${config[user]}" ]]; then _log WARN "malformed executioner ( \"${config[group]}:${config[user]}\" ) fallbacks to \"${_group}:${_user}\" ."; fi
  if [[ ! "${_gid}:${_uid}" = "${config[group_id]}:${config[user_id]}" ]]; then _log WARN "malformed executioner ( \"${config[group_id]}:${config[user_id]}\" ) fallbacks to \"${_gid}:${_uid}\" ."; fi

  _log debug "_group=[${_group}] ( ${_gid} )"
  _log debug "_user=[${_user}] ( ${_uid} )"

  if getent group "${_group}" >/dev/null 2>&1; then _log IGNORE "the group \"${_group}\" already exists ."
  elif [[ "${_group}" = "${_user}" ]]; then :;
  elif groupadd -g "${_gid}" "${_group}" 2>/dev/null; then _log INFO "create Tomcat group \"${_group}\" ( $(getent group "${_group}" | awk -F '[::]' '{print $3}') ) ."
  else _log ERROR "could not create group \"${_group}\" ."; fi

  if [[ ! "${result:-1}" = '0' ]]; then :;
  elif getent passwd "${_user}" >/dev/null 2>&1; then _log IGNORE "user \"${_user}\" already exists ."
  elif useradd -u "${_uid}" "${_user}" -d ${_basedir} >/dev/null 2>&1; then _log INFO "create user \"${_user}\" ( $(getent passwd "${_user}" | awk -F '[::]' '{print $3}') ) ."
  else _log ERROR "could not create user \"${_user}\" ."; result=1; fi

  if [[ ! "${result:-1}" = '0' ]]; then usermod -aG tty,${_group} ${_user}; fi
fi

if [[ ! "${result:-1}" = '0' ]]; then exit $((${result:-1})); fi

# download
if [[ -f "${_imagedir}/${_source}" ]]; then _log IGNORE "source already exists at \"${_imagedir}/${_source}\" ."
elif echo "${_url}" | grep -E '^https?' >/dev/null 2>&1; then _log INFO "downloading source from \"${_url}\" ..."; curl -fjkL "${_url}" -o "${_imagedir}/${_source}"
elif [[ -f "${_url}" ]]; then _log INFO "copying source from \"${_url}\" ..."; cp -p "${_url}" "${_imagedir}/${_source}"; fi

if [[ ! -f "${_imagedir}/${_source}" ]]; then _log ERROR "could not download source ."; result=1; fi

if [[ ! "${result:-1}" = '0' ]]; then exit $((${result:-1})); fi

# extract
_extract=$(tar tf "${_imagedir}/${_source}" | sed -n -e 1p | sed -e 's/\/.*//')
tar xf "${_imagedir}/${_source}" -C "${_workdir}"
if [[ ! -d "${_workdir}/${_extract}" ]]; then _log ERROR "could not extract source ."; result=1
elif ! mv "${_workdir}/${_extract}" "${_home}"; then _log ERROR "could not extract source to \"${_home}\" ."; result=1; fi

if [[ ! "${result:-1}" = '0' ]]; then exit $((${result:-1})); fi

# install tomcat-native
if ls /usr/lib64 | grep tcnative >/dev/null; then _log IGNORE "Tomcat native already installed ."
else
  _tomcat_native_url="${config[url_tcnative]}"
  if [[ $((_ver)) -ge 10 ]] && openssl version | grep -i 'OpenSSL 1.' >/dev/null; then _tomcat_native_url="${config[url_tcnative12]}"; fi
  _tomcat_native_source=$( echo "${_tomcat_native_url}" | sed -e 's/.*\///' )
  if [[ -f "${_imagedir}/${_tomcat_native_source}" ]]; then _log IGNORE "\"${_tomcat_native_source}\" already exists ."
  else _log INFO "downloading source from \"${_tomcat_native_url}\" ..."; curl -fjkL "${_tomcat_native_url}" -o "${_imagedir}/${_tomcat_native_source}"; fi
  if [[ -f "${_imagedir}/${_tomcat_native_source}" ]]; then
    _tomcat_native_extract=$(tar tf "${_imagedir}/${_tomcat_native_source}" | sed -n -e 1p | sed -e 's/\/.*//')
    tar xf "${_imagedir}/${_tomcat_native_source}" -C "${_workdir}"
    if [[ ! -d "${_workdir}/${_tomcat_native_extract}" ]]; then _log ERROR "could not extract Tomcat native source ."; result=1
    else
      _log INFO "installing Tomcat native ..."
      if ! bash -c "${packagemanager:-dnf} install -y automake apr-devel gcc openssl-devel" 1>/dev/null; then _log ERROR "could not install dependencies ."; result=1
      else cat <<_EOT_|bash
cd "${_workdir}/${_tomcat_native_extract}/native"
./configure \
--prefix=/usr \
--libdir=/usr/lib64 \
--with-java-home=${JAVA_HOME} \
--with-apr=/usr/bin/apr-1-config \
--with-ssl=/usr/include/openssl >/dev/null 2>&1 && \
  make >/dev/null 2>&1 && \
  make install >/dev/null 2>&1
_EOT_
        if ! ls /usr/lib64 | grep tcnative >/dev/null; then _log ERROR "Tomcat native install failed ."; result=1; fi
      fi
    fi
  else _log WARN "\"${_workdir}/${_extract}\" not contains Tomcat native ."; fi
fi

if [[ ! "${result:-1}" = '0' ]]; then exit $((${result:-1})); fi

# install tomcat-daemon
if ! ls "${_home}/bin" | grep commons-daemon-native >/dev/null; then _log WARN "\"${_workdir}/${_extract}\" not contains Tomcat daemon ."
else
  _tomcat_daemon_source=$(ls "${_home}/bin" | grep commons-daemon-native | grep -E '\.tar\.gz$')
  if [[ -f "${_home}/bin/${_tomcat_daemon_source}" ]]; then
    _tomcat_daemon_extract=$(tar tf "${_home}/bin/${_tomcat_daemon_source}" | sed -n -e 1p | sed -e 's/\/.*//')
    tar xf "${_home}/bin/${_tomcat_daemon_source}" -C "${_workdir}"
    if [[ ! -d "${_workdir}/${_tomcat_daemon_extract}" ]]; then _log ERROR "could not extract Tomcat native source ."; result=1
    else :;
      _log INFO "installing Tomcat daemon ..."
      if ! bash -c "${packagemanager:-dnf} install -y -q automake apr-devel gcc openssl-devel" 1>/dev/null; then _log ERROR "could not install dependencies ."; result=1
      else cat <<_EOT_|bash
cd "${_workdir}/${_tomcat_daemon_extract}/unix"
./configure \
--prefix=/usr \
--libdir=/usr/lib64 \
--with-java-home=${JAVA_HOME} >/dev/null 2>&1 && \
  make >/dev/null 2>&1
_EOT_
        if [[ ! -f ${_workdir}/${_tomcat_daemon_extract}/unix/jsvc ]]; then _log ERROR "Tomcat daemon install failed ."; result=1
        elif ! mv -f "${_workdir}/${_tomcat_daemon_extract}/unix/jsvc" "${_home}/bin/." 2>/dev/null; then _log ERROR "Tomcat daemon install failed ."; result=1
        elif [[ ! -f ${_home}/bin/jsvc ]]; then _log ERROR "Tomcat daemon install failed ."; result=1; fi
      fi
    fi
  else _log WARN "\"${_workdir}/${_extract}\" not contains Tomcat daemon ."; fi
fi

if [[ ! "${result:-1}" = '0' ]]; then exit $((${result:-1})); fi

# structure
_log INFO "building structure ..."
rm -rf ${_home}/{logs,temp,work}
chown -R "root:${_group}" ${_home}

# bin/
rm -rf ${_home}/bin/*.bat
chmod 0664 ${_home}/bin/*.*
chmod +x ${_home}/bin/{*.sh,jsvc}

# conf/
mkdir -p "${_home}/conf/Catalina/localhost"
[[ -f "/${_home}/conf/tomcat${_ver}.conf" ]] || cat <<_EOT_> "/${_home}/conf/tomcat${_ver}.conf"
# System-wide configuration file for tomcat services
# This will be loaded by systemd as an environment file,
# so please keep the syntax.
#
# There are 2 "classes" of startup behavior in this package.
# The old one, the default service named tomcat.service.
# The new named instances are called tomcat${_ver}@instance.service.
#
# Use this file to change default values for all services.
# Change the service specific ones to affect only one service.
# For tomcat8.service it's /etc/sysconfig/tomcat${_ver}, for
# tomcat${_ver}@instance it's /etc/sysconfig/tomcat${_ver}@instance.

# This variable is used to figure out if config is loaded or not.
TOMCAT_CFG_LOADED="1"

# In new-style instances, if CATALINA_BASE isn't specified, it will
# be constructed by joining TOMCATS_BASE and NAME.
TOMCATS_BASE="${_home}/instances/"

# Where your java installation lives
JAVA_HOME="${JAVA_HOME}"

# Where your tomcat installation lives
CATALINA_HOME="${_home}"

# System-wide tmp
CATALINA_TMPDIR="${_home}/temp"

# You can change your tomcat locale here
LANG="${LANG}"

# Run tomcat under the Java Security Manager
SECURITY_MANAGER="false"

# Time to wait in seconds, before killing process
# TODO(stingray): does nothing, fix.
# SHUTDOWN_WAIT="30"

# Whether to annoy the user with "attempting to shut down" messages or not
SHUTDOWN_VERBOSE="true"

# Set the TOMCAT_PID location
CATALINA_PID="${_home}/run/tomcat${_ver}.pid"

# Connector port is 8080 for this tomcat instance
#CONNECTOR_PORT="8080"

# If you wish to further customize your tomcat environment,
# put your own definitions here
# (i.e. LD_LIBRARY_PATH for some jdbc drivers)
CATALINA_OPTS="-server -Djava.awt.headless=true -Dfile.encoding=utf-8 -Xms${config[xms]:-256M} -Xmx${config[xmx]:-2G} -XX:+UseG1GC -Djava.security.egd=file:/dev/./urandom -Djava.library.path=/usr/lib64"

_EOT_
chown -R "${_user}:${_group}" ${_home}/conf/*
chmod 0770 ${_home}/conf
chmod 0664 ${_home}/conf/*.*
if [[ -d "/etc/tomcat${_ver}" ]]; then
  _timestamp=$(date +"%Y%m%d%H%M%S")
  mv "/etc/tomcat${_ver}" "/etc/tomcat${_ver}.saved.${_timestamp}"
  _log INFO "moved previous to \"/etc/tomcat${_ver}.saved.${_timestamp}\" ."
fi
mv "${_home}/conf" "/etc/tomcat${_ver}"
ln -fns "/etc/tomcat${_ver}" "${_home}/conf"

# logs
[[ -d "/var/log/tomcat${_ver}" ]] || mkdir -p "/var/log/tomcat${_ver}"
chown -R "${_user}:${_group}" /var/log/tomcat${_ver}
chmod -R 0770 /var/log/tomcat${_ver}
ln -fns "/var/log/tomcat${_ver}" "${_home}/logs"

# temp, work
[[ -d "/var/cache/tomcat${_ver}/temp" ]] || mkdir -p "/var/cache/tomcat${_ver}/temp"
[[ -d "/var/cache/tomcat${_ver}/work" ]] || mkdir -p "/var/cache/tomcat${_ver}/work"
chown -R "${_user}:${_group}" /var/cache/tomcat${_ver}
chmod -R 0770 /var/cache/tomcat${_ver}
ln -fns "/var/cache/tomcat${_ver}/temp" "${_home}/temp"
ln -fns "/var/cache/tomcat${_ver}/work" "${_home}/work"

# webapps
chown -R "${_user}:${_group}" ${_home}/webapps
chmod -R 0775 ${_home}/webapps
if [[ -d "/var/lib/tomcat${_ver}" ]]; then
  _timestamp=$(date +"%Y%m%d%H%M%S")
  mv "/var/lib/tomcat${_ver}" "/var/lib/tomcat${_ver}.saved.${_timestamp}"
  _log INFO "moved previous to \"/var/lib/tomcat${_ver}.saved.${_timestamp}\" ."
fi
mkdir -p "/var/lib/tomcat${_ver}"
chown -R "${_user}:${_group}" /var/lib/tomcat${_ver}
chmod -R 0770 /var/lib/tomcat${_ver}
mv "${_home}/webapps" "/var/lib/tomcat${_ver}/."
ln -fns "/var/lib/tomcat${_ver}/webapps" ${_home}/webapps

# instances
if [[ -d "/var/lib/tomcat${_ver}s" ]]; then
  _timestamp=$(date +"%Y%m%d%H%M%S")
  mv "/var/lib/tomcat${_ver}s" "/var/lib/tomcat${_ver}s.saved.${_timestamp}"
  _log INFO "moved previous to \"/var/lib/tomcat${_ver}s.saved.${_timestamp}\" ."
fi
mkdir -p "/var/lib/tomcat${_ver}s"
chown -R "${_user}:${_group}" /var/lib/tomcat${_ver}s
chmod -R 0775 /var/lib/tomcat${_ver}s
ln -fns "/var/lib/tomcat${_ver}s" ${_home}/instances

# pid(s)
[[ -d "/var/run/tomcat" ]] || mkdir -p "/var/run/tomcat"
chown -R "${_user}:${_group}" /var/run/tomcat
chmod -R 0775 /var/run/tomcat
ln -fns "/var/run/tomcat" "${_home}/run"

# manager GUI
if [[ ! "${config[manager]}" = '' ]] && [[ -f "${_home}/conf/tomcat-users.xml" ]]; then
  sed -i -e 's/<\/tomcat-users[^>]*>/<!-- \0 -->/' "${_home}/conf/tomcat-users.xml"
  cat <<_EOT_>> ${_home}/conf/tomcat-users.xml
  <role rolename="admin-gui" />
  <role rolename="admin-script" />
  <role rolename="manager-gui" />
  <role rolename="manager-jmx" />
  <role rolename="manager-script" />
  <role rolename="manager-status" />
  <user username="${config[manager]}" password="${config[manager_pw]}" roles="admin-gui,admin-script,manager-gui,manager-jmx,manager-script,manager-status" />
</tomcat-users>

_EOT_
fi

if [[ ! "${result:-1}" = '0' ]]; then _log ERROR "initialization failure ( structure ) ."; exit $((${result:-1})); fi

[[ -f "/etc/sysconfig/tomcat${_ver}" ]] || cat <<_EOT_> "/etc/sysconfig/tomcat${_ver}"
# Service-specific configuration file for tomcat. This will be sourced by
# the SysV init script after the global configuration file
# /etc/tomcat${_ver}/tomcat${_ver}.conf, thus allowing values to be overridden in
# a per-service manner.
#
# NEVER change the init script itself. To change values for all services make
# your changes in /etc/tomcat${_ver}/tomcat${_ver}.conf
#
# To change values for a specific service make your edits here.
# To create a new service create a link from /etc/init.d/<your new service> to
# /etc/init.d/tomcat${_ver} (do not copy the init script) and make a copy of the
# /etc/sysconfig/tomcat${_ver} file to /etc/sysconfig/<your new service> and change
# the property values so the two services won't conflict. Register the new
# service in the system as usual (see chkconfig and similars).
#

# Where your java installation lives
#JAVA_HOME="/usr/lib/jvm/java"

# Where your tomcat installation lives
#CATALINA_BASE="/usr/share/tomcat${_ver}"
#CATALINA_HOME="/usr/share/tomcat${_ver}"
#JASPER_HOME="/usr/share/tomcat${_ver}"
#CATALINA_TMPDIR="/var/cache/tomcat${_ver}/temp"

# You can pass some parameters to java here if you wish to
#JAVA_OPTS="-Xminf0.1 -Xmaxf0.3"

# Use JAVA_OPTS to set java.library.path for libtcnative.so
#JAVA_OPTS="-Djava.library.path=/usr/lib64"

# What user should run tomcat
#TOMCAT_USER="tomcat"

# You can change your tomcat locale here
#LANG="en_US"

# Run tomcat under the Java Security Manager
#SECURITY_MANAGER="false"

# Time to wait in seconds, before killing process
#SHUTDOWN_WAIT="30"

# Whether to annoy the user with "attempting to shut down" messages or not
#SHUTDOWN_VERBOSE="false"

# Set the TOMCAT_PID location
#CATALINA_PID="/var/run/tomcat${_ver}.pid"

# Connector port is 8080 for this tomcat instance
#CONNECTOR_PORT="8080"

# If you wish to further customize your tomcat environment,
# put your own definitions here
# (i.e. LD_LIBRARY_PATH for some jdbc drivers)

_EOT_
chown "root:${_group}" "/etc/sysconfig/tomcat${_ver}"
chmod 0644 /etc/sysconfig/tomcat${_ver}

# systemd
[[ -f "/etc/systemd/system/tomcat${_ver}.service" ]] || cat <<_EOT_> "/etc/systemd/system/tomcat${_ver}.service"
# Systemd unit file for default tomcat
#
# To create clones of this service:
# DO NOTHING, use tomcat${_ver}@.service instead.

[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking
EnvironmentFile=/etc/tomcat${_ver}/tomcat${_ver}.conf
Environment="NAME="
EnvironmentFile=-/etc/sysconfig/tomcat${_ver}

# replace "ExecStart" and "ExecStop" if you want tomcat runs as daemon
# ExecStart=/usr/share/tomcat${_ver}/bin/daemon.sh start
# ExecStop=/usr/share/tomcat${_ver}/bin/daemon.sh stop
ExecStart=/usr/share/tomcat${_ver}/bin/startup.sh
ExecStop=/usr/share/tomcat${_ver}/bin/shutdown.sh

SuccessExitStatus=143
User=${_user}
Group=${_group}

[Install]
WantedBy=multi-user.target

_EOT_
chmod 0644 /etc/systemd/system/tomcat${_ver}.service

cp -p "/etc/systemd/system/tomcat${_ver}.service" "/etc/systemd/system/tomcat${_ver}@.service"

sed -i -e "s/tomcat${_ver}@/\0name/g" \
-e 's/Environment="NAME=/\0\%I/g' \
-e "s/EnvironmentFile=-\/etc\/sysconfig\/tomcat${_ver}/\0@\%I/g" \
"/etc/systemd/system/tomcat${_ver}@.service"
chmod 644 /etc/systemd/system/tomcat${_ver}@.service

sed -i -e "s/Server port=\"8005\"/Server port=\"\${server.port.shutdown}\"/g" \
-e "s/Connector port=\"8080\"/Connector port=\"\${connector.port}\"/g" \
-e "s/Connector port=\"8009\"/Connector port=\"\${connector.port.ajp}\"/g" \
-e "s/redirectPort=\"8443\"/redirectPort=\"\${connector.port.redirect}\"/g" \
-e "s/Connector port=\"8443\"/Connector port=\"\${connector.port.ssl}\"/g" \
${_home}/conf/server.xml

cat <<_EOT_>> "${_home}/conf/catalina.properties"

# Customized properties for server.xml
server.port.shutdown=${config[shutdown_port]:-8005}
connector.port=${config[connector_port]:-8080}
connector.port.ajp=${config[connector_port_ajp]:-8009}
connector.port.ajp.accept.ip=${config[connector_port_ajp_accept_ip]:-127.0.0.1}
connector.port.ajp.secret=${config[connector_port_ajp_secret]:-}
connector.port.ajp.secret.required=$(if [[ ! "${config[connector_port_ajp_secret]:-}" = '' ]] && [[ $(( ${config[connector_port_ajp_secret_required]:-1} )) -eq 0 ]]; then echo 'true'; else echo 'false'; fi)
connector.port.redirect=${config[connector_port_redirect]:-8443}
connector.port.ssl=${config[connector_port_ssl]:-8443}

_EOT_

sed -i -e 's/<Engine name="Catalina" defaultHost="localhost">/<Engine name="Catalina" jvmRoute="origin" defaultHost="localhost">/' \
-e 's/<\/Service>/<\!-- \n\0/' \
-e 's/<\/Server>/\0\n -->/' \
"${_home}/conf/server.xml"

cat <<_EOT_>> ${_home}/conf/server.xml
    <Connector protocol="AJP/1.3" address="\${connector.port.ajp.accept.ip}" port="\${connector.port.ajp}" redirectPort="\${connector.port.redirect}"$(if [[ ! "${config[connector_port_ajp_secret]:-}" = '' ]]; then echo ' secret="${connector.port.ajp.secret}"'; fi) secretRequired="\${connector.port.ajp.secret.required}" />
  </Service>
</Server>

_EOT_


if [[ ! "${result:-1}" = '0' ]]; then _log FATAL "failed install Tomcat \"${_source}\" ."
elif ! systemctl daemon-reload >/dev/null 2>&1; then _log ERROR "failed install Tomcat \"${_source}\" ."; result=1
else
  _log SUCCESS "Tomcat server \"${_source}\" launched ."
  _log SUCCESS "install at \"${_home}\" ."
  _log SUCCESS ''
  _log SUCCESS "server startup command:"
  _log SUCCESS "(sudo) systemctl start tomcat${_ver}"
  _log SUCCESS ''
  _log SUCCESS "server shutdown command:"
  _log SUCCESS "(sudo) systemctl stop tomcat${_ver}"
fi
exit $((${result:-1}))
