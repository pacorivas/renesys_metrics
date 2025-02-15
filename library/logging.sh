#!/usr/bin/env bash

DATE_FORMAT="%d/%m/%Y %H:%M:%S"

function logeon() {
  # ${1} --> Type
  # ${2} --> Verbosity ( 4: Sistemas, 2: Normal/Usuario, 0: Quiet )
  # "${foo^}"

  LOG_STRING=$(date +"%d/%m/%Y %H:%M:%S")

  case ${1} in
  info)
    LOG_STRING="${LOG_STRING} ${GRN}[Info]${END} "
    ;;
  warning)
    LOG_STRING="${LOG_STRING} ${YEL}[Warning]${END} "
    ;;
  error)
    LOG_STRING="${LOG_STRING} ${RED}${BOLD}[Error]${END} "
    ;;
  none)
    LOG_STRING="${LOG_STRING} "
    ;;
  file)
    #LOG_STRING="${LOG_STRING}[${4}]"
    LOG_STRING="${LOG_STRING} ${YEL}[File]${END} "
    ;;
  *)
    LOG_STRING="${LOG_STRING} [NO DEFINIDO] "
    ;;
  esac

  PARAM_LOG=${2}
  [[ "${VERB_PARAM}" == "YES" ]] && PARAM_LOG=$(echo "${2}+2" | bc)
  [[ "${VERB_PARAM}" == "NO" ]] && PARAM_LOG=0

  case ${PARAM_LOG} in
  4) # (S)
    echo "${LOG_STRING} ${3}"
    ;;
  2) # (N)
    echo "${LOG_STRING} ${3}"
    ;;
  0) # quiet
    ;;
  esac

  [[ "${LOG_FILE_PARAM}" == "YES" ]] && echo "${LOG_STRING} ${3}" >> "${LOGFILE}"

}

function logeon_status() {
  LOG_STRING=$(date +"%d/%m/%Y %H:%M:%S")
  LOG_STRING="${LOG_STRING} ${GRN}[Info]${END} "
  echo "$LOG_STRING ${1}" >> "${LOGFILE}"
}
