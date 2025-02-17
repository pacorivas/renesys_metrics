#!/usr/bin/env bash

#!/usr/bin/env bash

[ "${TRACE}" != "" ] && set -x

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Load common vars
source ${SCRIPT_DIR}/../library/common_vars.sh
# logeo arguments: $1 (Info/Warning/Error) $2 (Info string) $3 SCREEN/EMAIL
source ${SCRIPT_DIR}/../library/logging.sh
# Load metrics functions
source ${SCRIPT_DIR}/../library/metrics.sh

# GLOBAL MySQL Variables
get_mysql_params "${SCRIPT_DIR}/restore_metrics.json"

while true
do
  FECHA_LOG=$(date +"%Y%m%d")
  LOGFILE="${SCRIPT_DIR}/restore_metrics_${FECHA_LOG}.log"
  STATUS_METRICS=$(cat "${SCRIPT_DIR}/restore_metrics_status")
  [[ "${STATUS_METRICS}" == "inactive" ]] && { sleep 30; continue; }
  PROCESING_FILE=$(grep "\[File\]" ${LOGFILE} |tail -1 |awk '{print $4}')
  NUMBER_OF_INSERTS=$(grep "INSERT" ${STATUS_METRICS}/${PROCESING_FILE} |wc -l)
  TABLE=${PROCESING_FILE%%.*}
  NUMBER_INSERTED=$(mysql -sN  --host=${MYSQL_HOST} --port=${MYSQL_PORT} --user=${MYSQL_USER} --password=${MYSQL_PASS} -e "SELECT * FROM ${MYSQL_DB}.${TABLE}" 2> /dev/null |wc -l)
  logeon_status "Table: ${TABLE} --> ${NUMBER_INSERTED} / ${NUMBER_OF_INSERTS}"
  sleep 10
done

exit 0
