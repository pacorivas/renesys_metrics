#!/usr/bin/env bash

# gzip ~/Downloads/2024-11-20/vhistoricos_uint64.2024-11-20.2024-11-21.sql
# cp ~/Downloads/2024-11-20/vhistoricos_uint64.2024-11-20.2024-11-21.sql.gz /tmp/mysqldumps
# cp ~/Downloads/2024-11-20/vhistoricos_uint16.2024-11-20.2024-11-21.sql.gz /tmp/mysqldumps
# cp ~/Downloads/2024-11-20/*.gz /tmp/mysqldumps

[ "${TRACE}" != "" ] && set -x

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Load common vars
source ${SCRIPT_DIR}/../library/common_vars.sh
# Load parameters library
source ${SCRIPT_DIR}/../library/parameters.sh
# logeo arguments: $1 (Info/Warning/Error) $2 (Info string) $3 SCREEN/EMAIL
source ${SCRIPT_DIR}/../library/logging.sh
# Load metrics functions
source ${SCRIPT_DIR}/../library/metrics.sh

#echo "${LOGFILE}"
#exit 0

LOG_FILE_PARAM="YES"
logeon info 2 ""
logeon info 2 "parsing arguments"
parse_args "$@"
check_args_restore_data
logeon info 0 ""

# GLOBAL MySQL Variables
parse_mysql_params "${SCRIPT_DIR}/restore_metrics.tpl" "${SCRIPT_DIR}/restore_metrics.json"


daemon_function() {
  while true; do
    sleep 10
    # Save folder where dump files are for processing
    echo "${PARAM_FOLDER}" > "${SCRIPT_DIR}/restore_metrics_status"
    while read -r DUMP_FILE
    do
      # logeon info 0 "Procesando fichero: ${DUMP_FILE}"
      ORIGINAL_FILE=$(basename -- "${DUMP_FILE}")
      FILE_EXTENSION="${ORIGINAL_FILE##*.}"
      FILE_NAME="${ORIGINAL_FILE%.*}"
      [[ "${FILE_EXTENSION}" == "gz" ]] && gunzip ${DUMP_FILE}
      [[ "${FILE_EXTENSION}" == "sql" ]] && FILE_NAME="${FILE_NAME}.${FILE_EXTENSION}"
      logeon file 0 "${FILE_NAME}"
      logeon info 0 "    - Restaurando fichero: ${PARAM_FOLDER}/${FILE_NAME}"
      NUMBER_OF_INSERTS=$(grep "INSERT" ${PARAM_FOLDER}/${FILE_NAME} |wc -l)
      logeon info 0 "    - NUMBER OF RECORDS TO RESTORE: ${NUMBER_OF_INSERTS}"
      TABLE_NAME=$(grep "Dumping data for table" /tmp/mysqldumps/vhistoricos_uint64.2024-11-20.2024-11-21.sql |awk -F\` '{print $2}')
      RESTORE_DATE=$(grep "INSERT" "${PARAM_FOLDER}/${FILE_NAME}" |head -n 1 |awk -F\' '{print $2}' |awk '{print $1}')
      RECORDS_IN_TABLE_NOW=$(mysql -sN --host=${MYSQL_HOST} --port=${MYSQL_PORT} \
                                       --user=${MYSQL_USER} --password=${MYSQL_PASS} \
                                       -e "SELECT COUNT(*) FROM cuadro_mandos.${TABLE_NAME} WHERE fecha BETWEEN '${RESTORE_DATE} 00:00:00' AND '${RESTORE_DATE} 23:59:59'" 2> /dev/null)
      if [[ "${RECORDS_IN_TABLE_NOW}" -gt 0 ]]
      then
        logeon warning 0 " - There are records from this day on this table. Limpieza"
        mysql -sN --host=${MYSQL_HOST} --port=${MYSQL_PORT} \
                  --user=${MYSQL_USER} --password=${MYSQL_PASS} \
                  -e "DELETE FROM cuadro_mandos.${TABLE_NAME} WHERE fecha BETWEEN '${RESTORE_DATE} 00:00:00' AND '${RESTORE_DATE} 23:59:59'" 2> /dev/null
        [[ "$?" -eq 0 ]] && logeon info 0 "      - Delete records from day ${YEL}${RESTORE_DATE}${END} in table ${YEL}${TABLE_NAME}${END} was ${GRN}OK${END}"
      fi
      INIT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
      mysql -sN --host=${MYSQL_HOST} --port=${MYSQL_PORT} \
                --user=${MYSQL_USER} --password=${MYSQL_PASS} \
                -e "REPLACE INTO cuadro_mandos.restore_metrics(file,restoration_table,restoration_date,info,restore_date_init,restore_date_end) VALUES ('${FILE_NAME}','${TABLE_NAME}','${RESTORE_DATE}','campo info','${INIT_DATE}','2000-01-01 00:00:00')" 2> /dev/null
      logeon info 0 "    - RESTORING records ..."
      mysql --host=${MYSQL_HOST} --port=${MYSQL_PORT} --user=${MYSQL_USER} --password=${MYSQL_PASS} ${MYSQL_DB} 2> /dev/null < "${PARAM_FOLDER}/${FILE_NAME}"
      [[ "$?" -eq 0 ]] && logeon info 0 "      - RESTORE records was ${GRN}OK${END}"
      END_DATE=$(date '+%Y-%m-%d %H:%M:%S')
      mysql -sN --host=${MYSQL_HOST} --port=${MYSQL_PORT} \
                --user=${MYSQL_USER} --password=${MYSQL_PASS} \
                -e "REPLACE INTO cuadro_mandos.restore_metrics(file,restoration_table,restoration_date,info,restore_date_init,restore_date_end) VALUES ('${FILE_NAME}','${TABLE_NAME}','${RESTORE_DATE}','campo info','${INIT_DATE}','${END_DATE}')" 2> /dev/null
      logeon info 0 "    - File: ${FILE_NAME} --> Processed"
      logeon info 0 ""
      rm -f "${PARAM_FOLDER}/${FILE_NAME}"
    done < <(find ${PARAM_FOLDER} -type f)
    echo "inactive" > "${SCRIPT_DIR}/restore_metrics_status"
  done
}

# Start the daemon
daemon_function &
echo $! > /var/run/mydaemon.pid
