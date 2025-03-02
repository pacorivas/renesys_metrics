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
declare -a TABLES=("vhistoricos") # COMENTAR. MODO TEST

parse_args "$@"
check_args_initial_restore
logeon info 2 ""
logeon info 2 "parsing arguments"
logeon info 2 ""

# GET EPOCH
#echo "Fecha Parama Inicial: ${PARAM_FROM_DATE} -- Fecha Parama Final: ${PARAM_TO_DATE}"
epoch_date "${PARAM_FROM_DATE}" "${PARAM_TO_DATE}"
#echo "Epoch Inicial: ${EPOCH_INICIAL} -- Epoch Final: ${EPOCH_FINAL}"
if [[ ${EPOCH_INICIAL} -gt ${EPOCH_FINAL} ]]
then
  FECHA_INICIAL="${PARAM_FROM_DATE}"
  FECHA_HASTA="${PARAM_TO_DATE}"
else
  FECHA_INICIAL="${PARAM_TO_DATE}"
  FECHA_HASTA="${PARAM_FROM_DATE}"
fi

logeon info 2 "----------------------------------------------------------------------"
logeon info 2 "Recuperando la base de datos desde el día ${YEL}${BOLD}${FECHA_INICIAL}${END} al día ${BOLD}${YEL}${FECHA_HASTA}${END}"
logeon info 2 "----------------------------------------------------------------------"
logeon info 2 ""

while true
do
  [[ "$(uname)" == "Darwin" ]] && DIRECTORY=$(date -jf "%Y-%m-%d" "${FECHA_INICIAL}" +"%Y-%m")
  [[ "$(uname)" != "Darwin" ]] && DIRECTORY=$(date --date="${FECHA_INICIAL}" "+%Y-%m")
  # GET FECHA_FINAL
  [[ "$(uname)" == "Darwin" ]] && FECHA_FINAL=$(date -j -v +1d -f "%Y-%m-%d" "${FECHA_INICIAL}" +%Y-%m-%d)
  [[ "$(uname)" != "Darwin" ]] && FECHA_FINAL=$(date -I -d "${FECHA_INICIAL} + 1 day")


  logeon info 2 "=============================================================="
  #logeon info 2 "${YEL}Recuperando${END} las Tablas de cuadro_mandos desde la fecha ${YEL}${FECHA_INICIAL}${END} hasta la fecha ${YEL}${FECHA_FINAL}${END}"
  logeon info 2 "${YEL}Recuperando${END} las Tablas de cuadro_mandos en la fecha ${YEL}${FECHA_INICIAL}${END}"
  logeon info 2 "=============================================================="
  logeon info 2 ""

  for TABLE in "${TABLES[@]}"
  do
    logeon info 2 "TABLA: ${GRN}${BOLD}${TABLE}${END}"
#test_dump "${DIA_BACKUP}" "${TABLE}" # COMENTAR. MODO TEST
    INIT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    save_begin "${DIRECTORY}/${TABLE}.${FECHA_INICIAL}.sql" "${TABLE}" "${FECHA_INICIAL}" "${INIT_DATE}"
    backup_day "${FECHA_INICIAL}" "${FECHA_FINAL}" "${TABLE}" "${DIRECTORY}"
    BACKUP_STATUS=$(cat "${DIRECTORY}/status_table.txt")
    if [[ "${BACKUP_STATUS}" != "false" ]]
    then
      END_DATE=$(date '+%Y-%m-%d %H:%M:%S')
      save_begin "${DIRECTORY}/${TABLE}.${FECHA_INICIAL}.sql" "${TABLE}" "${FECHA_INICIAL}" "${INIT_DATE}" "${END_DATE}"
      restore_day "${FECHA_INICIAL}" "${TABLE}" "${DIRECTORY}"
    fi
#test_restore "${DIA_BACKUP}" "${TABLE}" # COMENTAR. MODO TEST
    logeon info 2 "==============================================================================================="
  done # for TABLE
  [[ "${FECHA_INICIAL}" == "${FECHA_HASTA}" ]] && break
  [[ "$(uname)" == "Darwin" ]] && FECHA_INICIAL=$(date -j -v -1d -f "%Y-%m-%d" "${FECHA_INICIAL}" +%Y-%m-%d)
  [[ "$(uname)" != "Darwin" ]] && FECHA_INICIAL=$(date -I -d "${FECHA_INICIAL} - 1 day")
  # FECHA_INICIAL="${FECHA_FINAL}"
done # while true

exit 0


#  logeon error 2 "La fecha de inicio (--from-date) tiene que ser SUPERIOR a la final (--to-date)"
#  logeon error 2 "exit 101"
#  logeon error 2 ""
#  exit 101
#fi


#START_DAY=${PARAM_BEGINNING}
#DIA_BACKUP="${START_DAY}"
#logeon info 2 "Recuperando la base de datos desde el día ${YEL}${BOLD}${DIA_BACKUP}${END} y ${BOLD}${YEL}${PARAM_DAYS}${END} días hacia atrás"
#logeon info 2 ""

#for ((i = 0 ; i < ${PARAM_DAYS} ; i++)); do
#  echo "nada"
#done

# vhistoricos_uint64
# 2024-11-20
# SELECT COUNT(*) FROM cuadro_mandos.vhistoricos_uint64 WHERE fecha BETWEEN '2024-11-20 00:00:00' AND '2024-11-20 23:59:59';


# [[ "$(uname)" == "Darwin" ]] && FECHA_FINAL=$(date +%Y-%m-%d -d "${DIA_BACKUP} +1 day")
# [[ "$(uname)" == "Darwin" ]] && FECHA_FINAL=$(date -j -v +1d -f "%Y-%m-%d" "${DIA_BACKUP}" +%Y-%m-%d)

# START_DAY=$(date +%Y-%m-%d)
# START_DAY="2024-11-20"
