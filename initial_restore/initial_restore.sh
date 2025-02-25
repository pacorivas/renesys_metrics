#!/usr/bin/env bash

[ "${TRACE}" != "" ] && set -x

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Load common vars
source ${SCRIPT_DIR}/../library/common_vars.sh
# logeo arguments: $1 (Info/Warning/Error) $2 (Info string) $3 SCREEN/EMAIL
source ${SCRIPT_DIR}/../library/logging.sh
# Load metrics functions
source ${SCRIPT_DIR}/../library/metrics.sh
# Load parameters library
source ${SCRIPT_DIR}/../library/parameters.sh

function test_dump() {
  logeon info 2 "DUMP - ${1} - ${2}"
}
function test_restore() {
  logeon info 2 "RESTORE - ${1} - ${2}"
}

declare -a TABLES=("vhistoricos" "vhistoricos_bool" "vhistoricos_float" \
                    "vhistoricos_int16" "vhistoricos_int32" "vhistoricos_int64" \
                    "vhistoricos_int8" "vhistoricos_uint16" "vhistoricos_uint32" \
                    "vhistoricos_uint64" "vhistoricos_uint8")

parse_args "$@"
check_args_initial_restore
logeon info 2 ""
logeon info 2 "parsing arguments"
logeon info 0 ""

START_DAY=${PARAM_BEGINNING}
DIA_BACKUP="${START_DAY}"
logeon info 2 "Recuperando la base de datos desde el día ${YEL}${BOLD}${DIA_BACKUP}${END} y ${BOLD}${YEL}${PARAM_DAYS}${END} días hacia atrás"
logeon info 2 ""

for ((i = 0 ; i < ${PARAM_DAYS} ; i++)); do

  declare -a TABLES=("vhistoricos_int8") # COMENTAR. MODO TEST
  declare -a TABLES=("vhistoricos_uint64") # COMENTAR. MODO TEST

  for TABLE in "${TABLES[@]}"
  do
    [[ "$(uname)" == "Darwin" ]] && FECHA_FINAL=$(date -j -v -1d -f "%Y-%m-%d" "${DIA_BACKUP}" +%Y-%m-%d)
    [[ "$(uname)" != "Darwin" ]] && FECHA_FINAL=$(date -I -d "${DIA_BACKUP} - 1 day")
    logeon info 2 "DUMP de tabla ${YEL}${TABLE}${END} del día ${YEL}${DIA_BACKUP}${END}"
#test_dump "${DIA_BACKUP}" "${TABLE}" # COMENTAR. MODO TEST
    backup_day "${DIA_BACKUP}" "${TABLE}"
[[ "$(uname)" == "Darwin" ]] && DIRECTORY=$(date -jf "%Y-%m-%d" "${DIA_BACKUP}" +"%Y-%m")
[[ "$(uname)" != "Darwin" ]] && DIRECTORY=$(date --date="${DIA_BACKUP}" "+%Y-%m")
    BACKUP_STATUS=$(cat "${DIRECTORY}/status_table.txt")
    [[ "${BACKUP_STATUS}" != "false" ]] && restore_day "${DIA_BACKUP}" "${TABLE}"
#test_restore "${DIA_BACKUP}" "${TABLE}" # COMENTAR. MODO TEST
    logeon info 2 "======================================================================="
  done
  DIA_BACKUP="${FECHA_FINAL}"

done

exit 0

# vhistoricos_uint64
# 2024-11-20
# SELECT COUNT(*) FROM cuadro_mandos.vhistoricos_uint64 WHERE fecha BETWEEN '2024-11-20 00:00:00' AND '2024-11-20 23:59:59';


# [[ "$(uname)" == "Darwin" ]] && FECHA_FINAL=$(date +%Y-%m-%d -d "${DIA_BACKUP} +1 day")
# [[ "$(uname)" == "Darwin" ]] && FECHA_FINAL=$(date -j -v +1d -f "%Y-%m-%d" "${DIA_BACKUP}" +%Y-%m-%d)

# START_DAY=$(date +%Y-%m-%d)
# START_DAY="2024-11-20"

