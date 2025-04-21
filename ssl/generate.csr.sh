#!/bin/bash
set -ue -o pipefail
export LC_ALL=C

###
# generate.csr.sh
# https://github.com/furplag/archive/ssl/
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# a shorthand for Old-Fashioned generate CSR ( for SSL Certificates on website ) .
#
# Overview
#   usage
#   A. cat <<_EOT_| bash
#      declare -r cn=stargate.internal
#      declare -r c=JP
#      declare -r st=Hokkaido
#      declare -r l='Hakodate city'
#      declare -r o='Edo Shogunate'
#      source <(curl -fLsS https://raw.githubusercontent.com/furplag/archive/master/ssl/generate.csr.sh)
#      _EOT_
#   B. download, then custom configuration for your own .

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
if ! declare -p cn >/dev/null 2>&1; then declare -r cn=; fi
if ! declare -p c >/dev/null 2>&1; then declare -r c=; fi
if ! declare -p l >/dev/null 2>&1; then declare -r l=; fi
if ! declare -p st >/dev/null 2>&1; then declare -r st=; fi
if ! declare -p o >/dev/null 2>&1; then declare -r o=; fi
if ! declare -p ou >/dev/null 2>&1; then declare -r ou=; fi
if ! declare -p subdomains >/dev/null 2>&1; then declare -r subdomains=; fi
if ! declare -p genrsa >/dev/null 2>&1; then declare -r genrsa=0; fi
if ! declare -p keylength >/dev/null 2>&1; then declare -r keylength=2048; fi

if ! declare -p stamp >/dev/null 2>&1; then declare -r stamp=`date +'%Y-%m-%dT%H%M%S'`; fi
if ! declare -p name >/dev/null 2>&1; then declare -r name='generate.csr'; fi
if ! declare -p basedir >/dev/null 2>&1; then declare -r basedir="/opt/${name}"; fi
if ! declare -p workdir >/dev/null 2>&1; then declare -r workdir="${basedir}/${stamp}"; fi
if ! declare -p log_dir >/dev/null 2>&1; then declare -r logdir="${workdir}/logs"; fi
if ! declare -p log >/dev/null 2>&1; then declare -r log="${name}.log"; fi
if ! declare -p config >/dev/null 2>&1; then declare -A config=(
  [cn]="${cn:-}"
  [c]="${c:-}"
  [st]="${st:-}"
  [l]="${l:-}"
  [o]="${o:-}"
  [ou]="${ou:-}"
  [subdomains]="`linearize ${subdomains:-}`"
  [keylength]="${keylength:-}"
  [genrsa]="$(if [[ "${genrsa:-1}" = '0' ]]; then echo '0'; else echo '1'; fi)"

  [logging]=1
  [logdir]="${logdir:-}"
  [log]="${log:-}"
  [log_console]=0
  [debug]=1
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

  if [[ $(( ${config[logging]:-0} )) -eq 0 ]] && [[ -n "${config[logdir]}" ]] && [[ -n "${config[log]}" ]]; then
    [[ -d "${config[logdir]}" ]] || mkdir -p "${config[logdir]}"
  fi

  local _log="echo -e \"`date +"%Y-%m-%d %H:%M:%S"` - ${_symbol}: ${_message}\""

  if [[ $(( ${config[logging]:-0} + ${config[log_console]:-0} )) -eq 0 ]]; then bash -c "${_log}${_stderr} | tee -a \"${config[logdir]}/${config[log]}\""
  elif [[ $(( ${config[logging]:-0} )) -ne 0 ]]; then bash -c "${_log}${_stderr}";
  else bash -c "${_log} >>\"${config[logdir]}/${config[log]:-${log}}\""; fi

  return 0
}

###
# processing
#
# read configuration
if [[ " ${config[@]} " =~ ' initialized ' ]]; then :;
elif ! curl --version >/dev/null 2>&1; then _log FATAL "enable to command \"curl\" first"; result=1
elif ! tar --version >/dev/null 2>&1; then _log FATAL "enable to command \"tar\" first"; result=1
elif ! tee --version >/dev/null 2>&1; then _log FATAL "enable to command \"tee\" first"; result=1; fi

for _required in cn; do
  [[ "$(echo config[$_required])" = '' ]] && _log ERROR "${_required} must not be empty" && result=1;
done

_log DEBUG "config=(\\n$(for k in ${!config[@]}; do echo "  $k=${config[$k]}"; done)\\n)"

if [[ $(( ${result:-1} )) -ne 0 ]]; then exit $(( ${result:-1} )); fi
config[initialized]="${0:-${name}}"

declare -r _privkey="${workdir}/${config[cn]}.privkey"
declare -r _csr="${workdir}/${config[cn]}.csr"

# make structure
[ -d "${basedir}" ] || mkdir -p ${basedir}
[ -d "${workdir}" ] || mkdir -p ${workdir}
[ -d "${logdir}" ] || mkdir -p ${logdir}

# generate private key file
for n in 0 1 2; do openssl rand ${config[keylength]}00 >${workdir}/rand${n}; done
if [[ $(( ${config[genrsa]:-1} )) -eq 0 ]]; then openssl genrsa -rand ${workdir}/rand0:${workdir}/rand1:${workdir}/rand2 ${config[keylength]} >"${_privkey}";
else openssl ecparam -name secp384r1 -genkey -out ${_privkey}; fi

[ ! -f "${_privkey}" ] && _log ERROR "${_privkey} could not generate ." && result=1;
if [[ $(( ${result:-1} )) -ne 0 ]]; then exit $(( ${result:-1} )); fi

_log SUCCESS "private key \"${_privkey}\" successfully generated ."

declare _subject="/CN=${config[cn]}"
[ -z "${config[c]}" ] || _subject="${_subject}/C=${config[c]}"
[ -z "${config[l]}" ] || _subject="${_subject}/L=${config[l]}"
[ -z "${config[st]}" ] || _subject="${_subject}/ST=${config[st]}"
[ -z "${config[o]}" ] || _subject="${_subject}/O=${config[o]}"
[ -z "${config[ou]}" ] || _subject="${_subject}/OU=${config[ou]}"
if [ -n "${config[subdomains]}" ]; then
  cat <<_EOT_> ${workdir}/_extension.${config[cn]}.cnf
[extension.${config[cn]}]
subjectAltName=DNS:${config[cn]}$(echo ",DNS:${config[subdomains]}" | sed -e "s/ /.${config[cn]},DNS:/gi").${config[cn]}
_EOT_
  openssl req -new -key ${_privkey} -sha256 -out "${_csr}" -subj "${_subject}" -extensions "extension.${config[cn]}" -config ${workdir}/_extension.${config[cn]}.cnf
else openssl req -new -key ${_privkey} -sha256 -out "${_csr}" -subj "${_subject}"; fi

[ ! -f "${_csr}" ] && _log ERROR "${_csr} could not generate ." && result=1;
if [[ $(( ${result:-1} )) -ne 0 ]]; then exit $(( ${result:-1} )); fi

_log SUCCESS "CSR \"${_csr}\" successfully generated ."

exit $((${result:-1}))
