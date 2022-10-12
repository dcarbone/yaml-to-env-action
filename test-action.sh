#!/usr/bin/env bash
GITHUB_ENV="$(pwd)/test.env"
printf '' > $GITHUB_ENV

function _debug_log () { printf '[DEBUG] - %s' "${@}"; echo ""; }
function _join_by { local IFS="$1"; shift; echo "$*"; }
function _trim() { printf '%s' "${1}" | sed 's/^[[:blank:]]*//; s/[[:blank:]]*$//'; }
function _ltrim_one { printf '%s' "${1}" | sed 's/^[[:blank:]]//'; }
function _rtrim_one { printf '%s' "${1}" | sed 's/[[:blank:]]$//'; }
function _upper() { printf '%s' "${1}" | tr '[:lower:]' '[:upper:]'; }
function _env_name() {  _upper "${1}" | sed -E 's/[^a-zA-Z0-9_]/_/g'; }

_write_env_file_line() {
  _debug_log "${1} >> $GITHUB_ENV"
  printf '%s' "${1}" | sed -e 's/\\n/\n/g' >> $GITHUB_ENV
  printf '\n' >> $GITHUB_ENV
}

_write_kv_to_env_file() {
  local _n
  local _v
  local _re
  _n="$(_env_name "${1}")"
  _v="${2}"
  _re='\\n'
  if [[ "${_v}" =~ $_re ]]; then
    _write_env_file_line "${_n}<<EOF"
    _write_env_file_line "${_v}"
    _write_env_file_line 'EOF'
  else
    _write_env_file_line "${_n}=${_v}"
  fi
}

_parse_yq_output() {
  local _lines
  local _line
  local _split
  local _key
  local _value
  local _clean_value

  _lines=()
  readarray -t _lines <<< "${1}"

  _debug_log "${#_lines[@]} possible value(s) and / or comments seen in file"

  for _line in "${_lines[@]}"; do
    _debug_log "_line='${_line}'"

    if [ -z "${_line}" ]; then
      _debug_log "Skipping empty line"
      continue
    fi

    if [[ "${_line}" =~ ^# ]]; then
      _debug_log "Skipping comment line \"${_line}\""
      continue
    fi

    _split=()
    IFS=$'='; read -r -a _split <<< "${_line}"

    for (( i=0; i < "${#_split[@]}"; i++ )); do
      _debug_log "_split.${i}='${_split[$i]}'"
    done

    _key="$(_rtrim_one "${_split[0]}")"
    _value="$(_join_by '=' "${_split[@]:1}")"
    _clean_value="$(_ltrim_one "${_value}")"

    _debug_log "_key='${_key}'"
    _debug_log "_value='${_value}'"
    _debug_log "_clean_value='${_clean_value}'"

    _write_kv_to_env_file "${_key}" "${_clean_value}"

  done
}

_debug_log "Writing to \"$GITHUB_ENV\":"
_all_fields="$(yq -o p '.' "$(pwd)/test-values.yaml")"
_parse_yq_output "${_all_fields}"
