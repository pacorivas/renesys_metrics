#!/usr/bin/env bash

# parse_args
#
# parse configure.sh arguments
# Arguments:
# - Mandatory:
#   - client, environment, action and repository url (common)
# - Optional:
#   - setting, tags,repository branch, inventory, release, rpms (depending on repo)
#
# Returns: none (var setup)
function parse_args(){
  while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
      -f|--folder)
        shift
        PARAM_FOLDER="${1}"
        ;;
      -h|--host)
        shift
        PARAM_HOST="${1}"
        ;;
      -p|--port)
        shift
        PARAM_PORT="${1}"
        ;;
      -u|--user)
        shift
        PARAM_USER="${1}"
        ;;
      -s|--secret)
        shift
        PARAM_SECRET="${1}"
        ;;
      -d|--database)
        shift
        PARAM_DATABASE="${1}"
        ;;
      -b|--beginning)
        shift
        PARAM_BEGINNING="${1}"
        ;;
      --from-date)
        shift
        PARAM_FROM_DATE="${1}"
        ;;
      --to-date)
        shift
        PARAM_TO_DATE="${1}"
        ;;
      --days)
        shift
        PARAM_DAYS="${1}"
        ;;
      --help)
        PARAM_HELP="YES"
        ;;
      --verbose)
        VERB_PARAM="YES"
        ;;
      *)
        logeon info "Unknown option '$key'"
        ;;
    esac
    shift
  done
}

# check_args_deploy
#
# Check if required arguments are provided
# Arguments: none
# Returns: usage_auto-deploy if failure, none if correct
function check_args_restore_data(){
  if [[ "${PARAM_HELP}" == "YES" ]]; then
    usage_restore_data
  fi
  [[ "${VERB_PARAM}" == "YES" ]] && { logeon info 0 ""; logeon info 0 "Ejecutando el script en modo verbose"; }
  [[ "${PARAM_PATH}" != "" ]] && { logeon info 0 ""; logeon info 0 "Revisando el directorio: ${PARAM_PATH}"; }
}

# usage_auto-deploy
#
# Show how to launch script
# Arguments: none
# Returns: writes to stdout usage
function usage_restore_data() {
    LOGEO_SCREEN="YES"
    [[ "${PARAM_HELP}" != "YES" ]] && logeon error 2 "Parámetros incorrectos"
    logeon info 2 "Usage: $0 [ -p <PATH> ]"
    logeon info 2 ""
    logeon info 2 "[ OPTIONAL ]"
    logeon info 2 "  PATH: Path Directory where MySQL Dump Backups are."
    logeon info 2 ""
    logeon info 2 "Example: $0 -p /tmp"
    exit 101
}

function check_args_initial_restore() {
  [[ ! "${PARAM_FROM_DATE}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ || ! "${PARAM_TO_DATE}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && usage_initial_restore
  if [[ "${PARAM_HELP}" == "YES" ]]; then
    usage_initial_restore
  fi
  [[ "${VERB_PARAM}" == "YES" ]] && { logeon info 2 ""; logeon info 2 "Ejecutando el script en modo verbose"; }
}

function usage_initial_restore() {
    LOGEO_SCREEN="YES"
    [[ "${PARAM_HELP}" != "YES" ]] && logeon error "Parámetros incorrectos"
    logeon info 2 "Usage: $0 [ -p <PATH> ]"
    logeon info 2 ""
    logeon info 2 "[ OPTIONAL ]"
    logeon info 2 "  PATH: Path Directory where MySQL Dump Backups are."
    logeon info 2 ""
    logeon info 2 "Example: $0 -p /tmp"
    exit 101
}
