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
      --help)
        PARAM_HELP="YES"
        ;;
      --verbose)
        VERB_PARAM="YES"
        ;;
      *)
        logeo info "Unknown option '$key'"
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
    [[ "${PARAM_HELP}" != "YES" ]] && logeo error "Parámetros incorrectos"
    logeo info "Usage: $0 [ -p <PATH> ]"
    logeo info ""
    logeo info "[ OPTIONAL ]"
    logeo info "  PATH: Path Directory where MySQL Dump Backups are."
    logeo info ""
    logeo info "Example: $0 -p /tmp"
    exit 101
}
