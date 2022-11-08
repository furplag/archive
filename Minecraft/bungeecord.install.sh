#!/bin/bash
set -ue -o pipefail
export LC_ALL=C

###
# bungeecord.install.sh
# https://github.com/furplag/archive/Minecraft
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#

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
if ! declare -p name >/dev/null 2>&1; then declare -r name='waterfall'; fi
if ! declare -p basedir >/dev/null 2>&1; then declare -r basedir='/opt/bungeecord'; fi
if ! declare -p bindir >/dev/null 2>&1; then declare -r bindir="${basedir}/_bin"; fi
if ! declare -p imagedir >/dev/null 2>&1; then declare -r imagedir="${basedir}/_images"; fi
if ! declare -p log_dir >/dev/null 2>&1; then declare -r log_dir="${basedir}/_logs"; fi
if ! declare -p log >/dev/null 2>&1; then declare -r log="${name}.$(date +"%Y-%m-%d").log"; fi
if ! declare -p configuration_file >/dev/null 2>&1; then declare -r configuration_file="${basedir}/.bungeecord.install.config"; fi
if ! declare -p config >/dev/null 2>&1; then declare -A config=(
  [name]="${name:-}"
  [basedir]="${basedir:-}"
  [bindir]="${bindir:-}"
  [imagedir]="${imagedir:-}"
  [configuration_file]="${configuration_file:-}"

  [logging]=1
  [log_dir]="${log_dir:-}"
  [log]="${log:-}"
  [log_console]=0
  [debug]=0

  [group]='minecraft'
  [user]='minecraft'

  [url]="https://api.papermc.io/v2/projects/waterfall/versions/1.19/builds/506/downloads/waterfall-1.19-506.jar"
  [shutdown_delay_seconds]=15
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
# 1: instance name
config[name]="$(_1="${1:-}"; if [[ "${_1}" == '' ]]; then echo "${config[name]}"; else echo "${_1:-}"; fi)"
# 2: source url
config[url]="$(_2="$(linearize "${2:-}")"; if [[ "${_2}" == '' ]]; then echo "${config[url]}"; else echo "${_2:-}"; fi)"

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
elif ! java -version >/dev/null 2>&1; then _log FATAL "install JDK ( 16 or later ) first"; result=1
elif ! which screen >/dev/null 2>&1; then _log FATAL "enable to command \"screen\" first"; result=1
elif [[ ! -f "${config[configuration_file]}" ]]; then _log IGNORE "configuration_file ( \"${config[configuration_file]}\" ) not found"
else
  for readline in $(cat ${config[configuration_file]} | grep -v ^# | grep -vE "^\s*\[.+\]" | grep -E ^.+=.+$ | sed -e 's/^\s\+\|\s\+$//g' | sort -r); do
    config["${readline/=*}"]="${readline/*=}"
  done
fi

for _required in name basedir imgaedir url; do
  [[ "$(echo config[$_required])" = '' ]] && _log ERROR "${_required} must not be empty" && result=1
done

_log DEBUG "config=(\\n$(for k in ${!config[@]}; do echo "  $k=${config[$k]}"; done)\\n)"

if [[ $(("${result:-1}")) -ne 0 ]]; then exit $((${result:-1}));
else config[initialized]="${0:-${name}}"; fi

declare -r _basedir="$(_path="$(sanitize "${config[basedir]}")"; echo "${_path:-${basedir}}")"
if [[ ! "${_basedir}" = "${config[basedir]}" ]]; then _log WARN "malformed install path ( \"${config[basedir]}\" ) fallbacks to \"${_basedir}\" ."; fi
if [[ ! -d "${_basedir}" ]]; then mkdir -p "${_basedir}"; fi

declare -r _bindir="$(_path="$(sanitize "${config[bindir]}")"; echo "${_path:-${bindir}}")"
if [[ ! "${_bindir}" = "${config[bindir]}" ]]; then _log WARN "malformed install path ( \"${config[bindir]}\" ) fallbacks to \"${_bindir}\" ."; fi
if [[ ! -d "${_bindir}" ]]; then mkdir -p "${_bindir}"; fi

declare -r _imagedir="$(_path="$(sanitize "${config[imagedir]}")"; echo "${_path:-${imagedir}}")"
if [[ ! "${_imagedir}" = "${config[imagedir]}" ]]; then _log WARN "malformed directory path ( \"${config[imagedir]}\" ) fallbacks to \"${_imagedir}\" ."; fi
if [[ ! -d "${_imagedir}" ]]; then mkdir -p "${_imagedir}"; fi

declare -r _instance="$(_path="$(sanitize "${config[name]}")"; echo "${_path:-${name}}")"
if [[ ! "${_instance}" = "${config[name]}" ]]; then _log WARN "malformed instance name ( \"${config[name]}\" ) fallbacks to \"${_instance}\" ."; fi

declare -r _home="${_basedir}/${_instance}"
if [[ -d "${_home}" ]]; then _log ERROR "instance \"${_instance}\" already exists in \"${_home}\" ."; result=1
else mkdir -p "${_home}"; fi

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
_log debug "_bindir=[${_bindir}]"
_log debug "_imagedir=[${_imagedir}]"
_log debug "_instance=[${_instance}]"
_log debug "_home=[${_home}]"
_log debug "_url=[${_url}]"
_log debug "_source=[${_source}]"

if [[ $(("${result:-1}")) -ne 0 ]]; then exit $((${result:-1})); fi

if [[ ! -d "${_basedir}" ]]; then _log ERROR "could not create directory \"${_basedir}\" ."; result=1
elif [[ ! -d "${_bindir}" ]]; then _log ERROR "could not create directory \"${_bindir}\" ."; result=1
elif [[ ! -d "${_imagedir}" ]]; then _log ERROR "could not create directory \"${_imagedir}\" ."; result=1
elif [[ ! -d "${_basedir}/${_instance}" ]]; then _log ERROR "could not create directory \"${_basedir}/${_instance}\" ."; result=1
else
  declare -r _group="$(_name="$(sanitize "${config[group]}")"; echo "${_name:-minecraft}")"
  declare -r _user="$(_name="$(sanitize "${config[user]}")"; echo "${_name:-minecraft}")"
  if [[ ! "${_group}:${_user}" = "${config[group]}:${config[user]}" ]]; then _log WARN "malformed executioner ( \"${config[group]}:${config[user]}\" ) fallbacks to \"${_group}:${_user}\" ."; fi

  _log debug "_group=[${_group}]"
  _log debug "_user=[${_user}]"

  if getent group "${_group}" >/dev/null 2>&1; then _log IGNORE "the group \"${_group}\" already exists ."
  elif [[ "${_group}" = "${_user}" ]]; then :;
  elif groupadd "${_group}" 2>/dev/null; then _log INFO "create minecraft group \"${_group}\" ( $(getent group "${_group}" | awk -F '[::]' '{print $3}') ) ."
  else _log ERROR "could not create group \"${_group}\" ."; fi

  if [[ $(("${result:-1}")) -ne 0 ]]; then :;
  elif getent passwd "${_user}" >/dev/null 2>&1; then _log IGNORE "user \"${_user}\" already exists ."
  elif useradd "${_user}" -d ${_basedir} >/dev/null 2>&1; then _log INFO "create user \"${_user}\" ( $(getent passwd "${_user}" | awk -F '[::]' '{print $3}') ) ."
  else _log ERROR "could not create user \"${_user}\" ."; result=1; fi

  if [[ $(("${result:-1}")) -eq 0 ]]; then usermod -aG tty,${_group} ${_user}; fi
fi

if [[ $(("${result:-1}")) -ne 0 ]]; then exit $((${result:-1})); fi
for _d in "${_basedir}" "${_bindir}" "${_imagedir}" "${_basedir}/${_instance}"; do chown "${_user}:${_group}" "${_d}"; done

# install Minecraft server JAR
if [[ -f "${_imagedir}/${_source}" ]]; then _log IGNORE "server JAR already exists at \"${_imagedir}${_source}\" ."
elif echo "${_url}" | grep -E '^https?' >/dev/null 2>&1; then _log INFO "downloading server JAR from \"${_url}\" ..."; curl -fL "${_url}" -o "${_imagedir}/${_source}"
elif [[ -f "${_url}" ]]; then _log INFO "copying JDK binary from \"${_url}\" ..."; cp -p "${_url}" "${_imagedir}/${_source}"; fi

if [[ ! -f "${_imagedir}/${_source}" ]]; then _log ERROR "could not download server JAR ."; result=1
elif ! ln -s "${_imagedir}/${_source}" "${_home}/server.jar" >/dev/null 2>&1; then _log ERROR "could not create symlink from \"${_imagedir}/${_source}\" to \"${_instance}/server.jar\" ."; result=1; fi

if [[ $(("${result:-1}")) -ne 0 ]]; then exit $((${result:-1})); fi

if [[ -f "${_bindir}/startup" ]]; then _log IGNORE "common startup script ( \"${_bindir}/startup\" ) already exists ."
else cat <<_EOT_> "${_bindir}/startup"
#!/bin/bash
set -ue -o pipefail
export LC_ALL=C

###
# Startup script for Bungeecord proxy .
#

if ! declare -p instance_name >/dev/null 2>&1; then declare -r instance_name=; fi
if ! declare -p server_jar_path >/dev/null 2>&1; then declare -r server_jar_path=; fi

if ! declare -p server_xms >/dev/null 2>&1; then declare -r server_xms='512M'; fi
if ! declare -p server_xmx >/dev/null 2>&1; then declare -r server_xmx='512M'; fi

if ! declare -p result >/dev/null 2>&1; then declare -i result=0; fi

if ! java -version >/dev/null 2>&1; then echo "install JDK ( 16 or later ) first" >&2; result=1
elif ! which screen >/dev/null 2>&1; then echo "enable to command \"screen\" first" >&2; result=1
elif [[ "\${instance_name}" = '' ]]; then echo 'instance_name must not be empty' >&2; result=1
elif [[ "\${server_jar_path}" = '' ]]; then echo 'server JAR must not be empty' >&2; result=1
elif [[ ! -f "\${server_jar_path}" ]]; then echo "server JAR not found ( \"\${server_jar_path}\" ) ." >&2; result=1; fi

if [[ \$(("\${result:-1}")) -ne 0 ]]; then exit \$((\${result:-1})); fi

screen -UmdS \${instance_name} java -server \\
-Xms${server_xms:-512M} \\
-Xmx${server_xmx:-512M} \\
-XX:+UseG1GC \\
-XX:G1HeapRegionSize=4M \\
-XX:+UnlockExperimentalVMOptions \\
-XX:+ParallelRefProcEnabled \\
-XX:+AlwaysPreTouch \\
-Dfile.encoding=UTF-8 \\
-Duser.language=ja \\
-Duser.country=JP \\
-jar "${server_jar_path}"

_EOT_
fi

if [[ -f "${_home}/startup" ]]; then _log IGNORE "startup script ( \"${_home}/startup\" ) already exists ."
else cat <<_EOT_> "${_home}/startup"
#!/bin/bash

###
# Startup script for Minecraft server ( ${_instance} ) .
#

declare -r instance_name='${_instance}'
declare -r server_jar_path='${_home}/server.jar'

cd "${_home}"
source "${_bindir}/startup"

_EOT_
  [[ -f "${_home}/startup" ]] && chmod +x "${_home}/startup"
fi

[[ -f "${_home}/eula.txt" ]] || echo 'eula=true' >"${_home}/eula.txt"

chown -R ${_group}:${_user} "${_home}" >/dev/null 2>&1

if [[ -f "/etc/systemd/system/bungeecord@.service" ]]; then _log IGNORE "systemd \"/etc/systemd/system/bungeecord@.service\" already exists ."
else cat <<_EOT_> "/etc/systemd/system/bungeecord@.service"
[Unit]
Description=Minecraft Bungeecord proxy %i
After=network.target

[Service]
Type=forking

User=${_user}
Group=${_group}

PrivateUsers=true
ProtectSystem=full
ProtectHome=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true

WorkingDirectory=${_basedir}/%i
ExecStart=${_basedir}/%i/startup
ExecStop=/bin/bash -c "waits=$(_i=${config[shutdown_delay_seconds]}; if [[ $((${_i:-0})) -lt 0 ]]; then echo '0'; else echo "${_i:-0}"; fi); while [[ \$((waits)) -gt 0 ]]; do screen -p 0 -S %i -X eval \"stuff 'say the world freezing, at least in \$waits sec ...'\\015\"; waits=\$((waits - 5)); sleep 5; done"
ExecStop=/bin/bash -c "screen -p 0 -S %i -X eval 'stuff \"save-all\"\\015'"
ExecStop=/bin/sleep 5
ExecStop=/bin/bash -c "screen -p 0 -S %i -X eval 'stuff \"stop\"\\015'"

Restart=no
KillMode=none

[Install]
WantedBy=multi-user.target

_EOT_
fi

if [[ $(("${result:-1}")) -ne 0 ]]; then _log FATAL "failed install Minecraft Bungeecord proxy \"${_source}\" ."
elif ! systemctl daemon-reload >/dev/null 2>&1; then _log ERROR "failed install Minecraft Bungeecord proxy \"${_source}\" ."; result=1
else
  _log SUCCESS "Minecraft Bungeecord proxy \"${_source}\" ( instance: \"${_instance}\" ) launched ."
  _log SUCCESS ''
  _log SUCCESS "server startup command:"
  _log SUCCESS "(sudo) systemctl start bungeecord@${_instance}"
  _log SUCCESS ''
  _log SUCCESS "server shutdown command:"
  _log SUCCESS "(sudo) systemctl stop bungeecord@${_instance}"
fi
exit $((${result:-1}))
