#!/usr/bin/env bash

# GET Vault Status
#
# Arguments: $1 (ROLE_ID) $2 (SECRET_ID)
# Returns:
# 	0 - vault status ok
# 	1 - vault status KO
function parse_mysql_params()
{
	local PARAM_TPL_FILE=${1}
	local PARAM_JSON_FILE=${2}

  jq . "${1}" > "${2}"

  [[ "${PARAM_HOST}" != "" ]] && jq ".host = \"${PARAM_HOST}\"" "${PARAM_JSON_FILE}" > "${PARAM_JSON_FILE}.tmp" && mv "${PARAM_JSON_FILE}.tmp" "${PARAM_JSON_FILE}"
  [[ "${PARAM_PORT}" != "" ]] && jq ".mysql_port = \"${PARAM_PORT}\"" "${PARAM_JSON_FILE}" > "${PARAM_JSON_FILE}.tmp" && mv "${PARAM_JSON_FILE}.tmp" "${PARAM_JSON_FILE}"
  [[ "${PARAM_USER}" != "" ]] && jq ".mysql_user = \"${PARAM_USER}\"" "${PARAM_JSON_FILE}" > "${PARAM_JSON_FILE}.tmp" && mv "${PARAM_JSON_FILE}.tmp" "${PARAM_JSON_FILE}"
  [[ "${PARAM_SECRET}" != "" ]] && jq ".mysql_pass = \"${PARAM_SECRET}\"" "${PARAM_JSON_FILE}" > "${PARAM_JSON_FILE}.tmp" && mv "${PARAM_JSON_FILE}.tmp" "${PARAM_JSON_FILE}"
  [[ "${PARAM_DATABASE}" != "" ]] && jq ".mysql_db = \"${PARAM_DATABASE}\"" "${PARAM_JSON_FILE}" > "${PARAM_JSON_FILE}.tmp" && mv "${PARAM_JSON_FILE}.tmp" "${PARAM_JSON_FILE}"

#  MYSQL_HOST=$(jq -r '.host' "${PARAM_JSON_FILE}")
#  MYSQL_PORT=$(jq -r '.mysql_port' "${PARAM_JSON_FILE}")
#  MYSQL_USER=$(jq -r '.mysql_user' "${PARAM_JSON_FILE}")
#  MYSQL_PASS=$(jq -r '.mysql_pass' "${PARAM_JSON_FILE}")
#  MYSQL_DB=$(jq -r '.mysql_db' "${PARAM_JSON_FILE}")
}

function get_mysql_params()
{
	local PARAM_JSON_FILE=${1}

  MYSQL_HOST=$(jq -r '.host' "${PARAM_JSON_FILE}")
  MYSQL_PORT=$(jq -r '.mysql_port' "${PARAM_JSON_FILE}")
  MYSQL_USER=$(jq -r '.mysql_user' "${PARAM_JSON_FILE}")
  MYSQL_PASS=$(jq -r '.mysql_pass' "${PARAM_JSON_FILE}")
  MYSQL_DB=$(jq -r '.mysql_db' "${PARAM_JSON_FILE}")
}

function backup_day()
{
  local FECHA_INICIO="${1}"
  local TABLA="${2}"

  [[ "$(uname)" == "Darwin" ]] && DIRECTORY=$(date -jf "%Y-%m-%d" "${FECHA_INICIO}" +"%Y-%m")
  [[ "$(uname)" != "Darwin" ]] && DIRECTORY=$(date --date="${FECHA_INICIO}" "+%Y-%m")
  mkdir -p ${DIRECTORY}
  echo "false" > "${DIRECTORY}/status_table.txt"
  ARCHIVO="${DIRECTORY}/${TABLA}.${FECHA_INICIO}.sql"
  AHORA=$(date +%Y-%m-%d)
  if [[ "${AHORA}" == "${FECHA_INICIO}" ]]; then
      echo "Backup mismo dia" > "${ARCHIVO}.DiaIncompleto.txt"
  fi
  #echo "mysqldump --defaults-file=bbdd.cnf --defaults-group-suffix=_tabla --order-by-primary cuadro_mandos $TABLA --where=\"fecha>=\'$FECHA_INICIO\' AND fecha\<\'$FECHA_FIN\'\" | grep -v \"^LOCK TABLES\" | grep -v \"^UNLOCK TABLES\" | gzip -9c > $FECHA_INICIO/$TABLA.$FECHA_INICIO.$FECHA_FIN.sql.gz"
  logeon info 2 "Haciendo DUMP de la Tabla ${YEL}${TABLA}${END} en la fecha ${YEL}${FECHA_INICIO}${END}"
  sleep 1
  start=$(date +%s)
  mysqldump --defaults-file=bbdd.cnf \
            --defaults-group-suffix=_master \
              --no-create-info \
              --insert-ignore \
              --skip-extended-insert \
              --order-by-primary \
            cuadro_mandos ${TABLA} \
            --where="date(fecha)>=${FECHA_INICIO}" \
            > ${ARCHIVO}
  retVal=$?
  if [ ${retVal} -ne 0 ]; then
    logeon error 2 "Fallo al hacer DUMP de la tabla ${YEL}${TABLA}${END} en el día ${YEL}${FECHA_INICIO}${END}"
    echo "Dump error tabla ${TABLA}_${FECHA_INICIO}" >> "${DIRECTORY}/tablas_con_error.txt"
  else
    logeon info 2 "  - Backup del día ${YEL}${FECHA_INICIO}${END} de la tabla ${YEL}${TABLA}${END} ${GRN}${BOLD}Ok${END}"
    end=$(date +%s)
    runtime=$((end-start))
    logeon info 2 "  - Backup de ${TABLA} en la fecha ${FECHA_INICIO} requiere ${GRN}${BOLD}${runtime} segundos${END}"
    echo "true" > "${DIRECTORY}/status_table.txt"
  fi
}

function restore_day()
{
  local FECHA_INICIO="${1}"
  local TABLA="${2}"

  [[ "$(uname)" == "Darwin" ]] && DIRECTORY=$(date -jf "%Y-%m-%d" "${FECHA_INICIO}" +"%Y-%m")
  [[ "$(uname)" != "Darwin" ]] && DIRECTORY=$(date --date="${FECHA_INICIO}" "+%Y-%m")
  ARCHIVO="${DIRECTORY}/${TABLA}.${FECHA_INICIO}.sql"

  logeon info 2 "Restaurando la Tabla ${YEL}${TABLA}${END} en la fecha ${YEL}${FECHA_INICIO}${END}"
  #echo "mysql --defaults-file=bbdd.cnf --defaults-group-suffix=_restore cuadro_mandos < $DIA_BACKUP/cuadro_mandos_procedures.sql"
  start=$(date +%s)
  mysql --defaults-file=bbdd.cnf cuadro_mandos_new < "${ARCHIVO}"
  retVal=$?
  if [ ${retVal} -ne 0 ]; then
    logeon error 2 "Fallo al Restaurar la tabla ${YEL}${TABLA}${END} en el día ${YEL}${FECHA_INICIO}${END}"
    echo "Restaurar error tabla ${TABLA}_${FECHA_INICIO}" >> "${DIRECTORY}/tablas_con_error.txt"
  else
    logeon info 2 "  - Restauración del día ${YEL}${FECHA_INICIO}${END} de la tabla ${YEL}${TABLA}${END} ${GRN}${BOLD}Ok${END}"
    end=$(date +%s)
    runtime=$((end-start))
    logeon info 2 "  - Restauración de la ${TABLA} en la fecha ${FECHA_INICIO} requiere ${GRN}${BOLD}${runtime} segundos${END}"
    echo "true" > "${DIRECTORY}/status_table.txt"
  fi
  # logeon info 2 ""
}

#  echo "mysql --defaults-file=bbdd.cnf --defaults-group-suffix=_restore cuadro_mandos < $DIA_BACKUP/cuadro_mandos_procedures.sql"
#  mysql --defaults-file=bbdd.cnf --defaults-group-suffix=_restore cuadro_mandos < $DIA_BACKUP/cuadro_mandos_procedures.sql
#  echo "mysql --defaults-file=bbdd.cnf --defaults-group-suffix=_restore cuadro_mandos < CreateTableHistoricos.sql"
#  mysql --defaults-file=bbdd.cnf --defaults-group-suffix=_restore cuadro_mandos < CreateTableHistoricos.sql
#  echo "mysql --defaults-file=bbdd.cnf --defaults-group-suffix=_restore cuadro_mandos < $DIA_BACKUP/cuadro_mandos_sin_historicos.sql"
#  mysql --defaults-file=bbdd.cnf --defaults-group-suffix=_restore cuadro_mandos < $DIA_BACKUP/cuadro_mandos_sin_historicos.sql

#    mysqldump --defaults-file=bbdd.cnf \
#              --defaults-group-suffix=_tabla \
#              --no-create-info \
#              --insert-ignore \
#              --skip-extended-insert \
#              --order-by-primary \
#              cuadro_mandos ${TABLA} \
#              --where="fecha>='${FECHA_INICIO}' AND fecha<'${FECHA_FIN}'" \
#         |grep -v "^LOCK TABLES" | grep -v "^UNLOCK TABLES" |gzip -9c > ${ARCHIVO}
