#!/usr/bin/env bash

function _join_by { local IFS="$1"; shift; echo "$*"; }
function _trim() { printf '%s' "${1}" | sed 's/^[[:blank:]]*//; s/[[:blank:]]*$//'; }
function _ltrim_one { printf '%s' "${1}" | sed 's/^[[:blank:]]//'; }
function _rtrim_one { printf '%s' "${1}" | sed 's/[[:blank:]]$//'; }
function _upper() { printf '%s' "${1}" | tr '[:lower:]' '[:upper:]'; }
function _env_name() {  _upper "${1}" | sed -E 's/[^a-zA-Z0-9_]/_/g'; }

_write_env_file_line() {
  printf '%s' "${1}" | sed -e 's/\\n/\n/g' >> "$GITHUB_ENV"
  printf '\n' >> "$GITHUB_ENV"
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

# sourced from https://stackoverflow.com/a/17841619
_join_by() {
  local IFS="$1"
  shift
  echo "$*"
}

_yaml_keys=()
_env_names=()

_lines=()
readarray -t _lines <<< "$(yq -o p '.' "$YAMLTOENV_YAML_FILE")"

for _line in "${_lines[@]}"; do
  if [ -z "${_line}" ]; then
    continue
  fi

  if [[ "${_line}" =~ ^# ]]; then
    continue
  fi

  _split=()
  IFS=$'='; read -r -a _split <<< "${_line}"

  _key="$(_rtrim_one "${_split[0]}")"
  _value="$(_join_by '=' "${_split[@]:1}")"
  _clean_value="$(_ltrim_one "${_value}")"

  if [[ "${YAMLTOENV_MASK_VARS}" == 'true' ]]; then
    # sourced https://dev.to/yuyatakeyama/mask-multiple-lines-text-in-github-actions-workflow-1a0
    echo "::add-mask::$(echo "$_clean_value" | sed ':a;N;$!ba;s/%/%25/g' | sed ':a;N;$!ba;s/\r/%0D/g' | sed ':a;N;$!ba;s/\n/%0A/g')"
  fi

  _yaml_keys+=("${_key}")
  _env_names+=("$(_env_name "${_key}")")

  _write_kv_to_env_file "${_key}" "${_clean_value}"

done

echo "var-count=${#_env_names[@]}" >> "$GITHUB_OUTPUT"
echo "yaml-keys=$(_join_by "," "${_yaml_keys[@]}")" >> "$GITHUB_OUTPUT"
echo "env-names=$(_join_by "," "${_env_names[@]}")" >> "$GITHUB_OUTPUT"
