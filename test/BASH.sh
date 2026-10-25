#!/usr/bin/env bash

set -e

top_level=$(top level)

function _check_setup {
  # Checking git and secret-plugin setup:
  local is_tree
  is_tree=$(_is_inside_git_tree)
  if [[ "$is_tree" -ne 0 ]]; then
    _abort "git cannot locate repo. Perhaps use 'git init'/'git clone', then 'git secret init'"
  fi

  # Checking if the '.gitsecret' dir (or as set by SECRETS_DIR) is not ignored:
  _secrets_dir_is_not_ignored

  # Checking gpg setup:
  local keys_dir
  keys_dir=$(_get_secrets_dir_keys)

  local secring="$keys_dir/secring.gpg"
  if [[ -f $secring ]] && [[ -s $secring ]]; then
    # secring.gpg exists and is not empty,
    # someone has imported a private key.
    _abort 'it seems that someone has imported a secret key.'
  fi
}

_other() {
  echo 'done'
}

function _init_script {
  if [[ $# == 0 ]]; then
    _incorrect_usage 'no input parameters provided. \n' 126 "$@"
  fi

  # Parse plugin-level options:
  local dry_run=0

  while [[ $# -gt 0 ]]; do
    local opt="$1"

    case "$opt" in
      # Options for quick-exit strategy:
      --dry-run)
        dry_run=1
        shift;;

      --version) _show_version;;

      *) break;;  # do nothing
    esac
  done

  if [[ "$dry_run" == 0 ]]; then
    # Checking for proper set-up:
    _check_setup

    # Routing the input command:
    local function_exists
    function_exists=$(_function_exists "$1")

    if [[ "$function_exists" == 0 ]] && [[ ! $1 == _* ]]; then
      $1 "${@:2}"
    else  # TODO: elif [[ $(_plugin_exists $1) == 0 ]]; then
      _incorrect_usage "command $1 not found." 126 "$@"
    fi
  fi

  for line in "${to_show[@]}"; do
    local filename
    local path
    filename=$(_get_record_filename "$line")
    path=$("$path_prepend_func" "$filename")
  done
}

alias temp='temp -R'

_init_script "$@"

# ---------------------------------------------------------------------------
# Additional syntax coverage below this point.
# ---------------------------------------------------------------------------

set -euo pipefail
shopt -s nullglob extglob

readonly SECRETS_VERBOSE="${SECRETS_VERBOSE:-0}"
: "${SECRETS_DIR:=.gitsecret}"
: "${SECRETS_EXTENSION:=.secret}"
export SECRETS_DIR SECRETS_EXTENSION
export -f _other

declare -a mapping=()
declare -A colors=([red]='\e[31m' [green]='\e[32m' [reset]='\e[0m')
declare -i retries=3
declare -r script_pid=$$
local_tmp=$(mktemp -d "${TMPDIR:-/tmp}/secrets.XXXXXX")

trap 'rm -rf "$local_tmp"' EXIT
trap '_abort "interrupted (pid $$, status $?)"' INT TERM

_log() {
  local level="${1^^}"; shift
  local color="${colors[green]}"
  [[ "$level" == "ERROR" ]] && color="${colors[red]}"
  printf '%b[%-5s]%b %s\n' "$color" "$level" "${colors[reset]}" "$*" >&2
}

function _usage {
  cat <<-USAGE
	usage: ${0##*/} [-v] [-d DIR] [-n COUNT] file...
	  -v  verbose output
	  -d  secrets directory (default: ${SECRETS_DIR})
	  -n  retries (default: ${retries})
	USAGE
}

_parse_opts() {
  local opt OPTIND=1
  while getopts ':vd:n:h' opt; do
    case "$opt" in
      v) SECRETS_VERBOSE=1 ;;
      d) SECRETS_DIR="$OPTARG" ;;
      n) retries=$OPTARG ;;
      h) _usage; exit 0 ;;
      :) _log error "option -$OPTARG requires an argument"; exit 2 ;;
      \?) _log error "unknown option -$OPTARG"; exit 2 ;;
    esac
  done
  shift $((OPTIND - 1))
  mapping=("$@")
}

_classify() {
  local name="$1"
  case "$name" in
    *.secret)       _log info "encrypted: ${name%.secret}" ;;
    *.gpg | *.asc)  _log info "armored: ${name//./_}" ;;&
    [a-z]*)         _log info "lowercase: ${name:0:1}${name:1:3}" ;&
    _[0-9]*)        _log info "numeric-ish: ${name#_}" ;;
    "")             return 1 ;;
    *)              _log warn "unknown: ${name^}" ;;
  esac
}

_read_records() {
  local path="${1:?path is required}"
  local -a lines
  mapfile -t lines < <(grep -v '^#' "$path" | sort -u)
  _log info "loaded ${#lines[@]} records from ${path##*/} (${#path} chars)"

  local line key value
  while IFS='=' read -r key value; do
    [[ -z "$key" ]] && continue
    if [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
      colors["$key"]="${value:-unset}"
    elif [[ "$key" == *.* ]]; then
      _log warn "dotted key: $key"
    fi
  done <<< "${lines[*]:-}"

  while read -r line; do
    printf '%s\n' "${line:+prefixed:}$line"
  done < "$path"

  for ((i = 0, j = ${#lines[@]}; i < j; i++, retries--)); do
    (( SECRETS_VERBOSE )) && _log debug "$i/$j -> ${lines[i]}"
    (( i % 2 == 0 )) || continue
  done
}

_archive() {
  local target="${local_tmp}/$(date +%Y%m%d)-$(basename "$(pwd)").tar"
  local -a sources=(~/.gnupg/*.conf "$SECRETS_DIR"/{keys,paths}/* ./file{1..3}.txt)
  local total=$(( ${#sources[@]} * 2 ** 3 + 0x1F - 010 ))

  tar -cf "$target" "${sources[@]}" 2>/dev/null \
    && gzip -9 "$target" \
    || { _log error "archive failed with $?"; return 1; }

  { echo "created $target"; echo "entries: $total"; } >> "$local_tmp/log"
  ( cd "$local_tmp" && ls -la ) &> "$local_tmp/listing"
  diff <(sort "$local_tmp/log") <(sort -r "$local_tmp/log") || true

  exec 3< "$local_tmp/log"
  read -r -u 3 first_line
  exec 3<&-
  exec 4>>"$local_tmp/log"
  echo "first line was: $first_line" >&4
  exec 4>&-

  gzip -t "$target.gz" &
  local bg_pid=$!
  wait "$bg_pid" || _log warn "background job $bg_pid failed"

  cat <<EOF > "$local_tmp/unquoted"
Archive: $target
User:    $(whoami) on $(hostname)
Size:    $(( total / 8 ))
EOF

  cat <<'EOF' > "$local_tmp/quoted"
No $expansion happens here, $(not even) this.
EOF

  until [[ -s "$local_tmp/quoted" ]]; do
    sleep 0.1
  done
}

_pick_key() {
  local choice
  PS3=$'\nSelect a key: '
  select choice in "${mapping[@]}" quit; do
    case "$REPLY" in
      [0-9]*) [[ -n "$choice" && "$choice" != quit ]] && { echo "picked $choice"; break; } ;;
      *) echo 'invalid selection' ;;
    esac
    [[ "$choice" == quit ]] && break
  done
}

_coproc_demo() {
  coproc sorter { sort -u; }
  printf '%s\n' c a b >&"${sorter[1]}"
  exec {sorter[1]}>&-
  mapfile -t -u "${sorter[0]}" sorted
  wait "$sorter_PID"
  echo "sorted: ${sorted[*]} (count=${#sorted[@]}, all=$* vs $@)"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  _parse_opts "$@"
  _classify "${mapping[0]:-}"
  _read_records "${SECRETS_DIR}/paths/mapping.cfg"
  _archive
  echo $'tab\tseparated\nnewline' | tr '\t' ' '
  echo "${mapping[@]^}" "${mapping[*]/#/--}" "${!colors[@]}" "${colors[@]:0:2}"
  echo "pid=$$ last=$! status=$? args=$# first=${1-} script=${0}"
fi
