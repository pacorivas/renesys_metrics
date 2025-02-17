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
