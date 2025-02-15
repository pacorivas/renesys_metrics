#!/usr/bin/env bash

# IP_ADDRESS=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -Ev '127.0.0.1|172.17')
SCRIPT_SERVER=$(hostname)
SCRIPT_NAME=${0##*/}
SCRIPT_NAME_NO_EXT=${SCRIPT_NAME%%.*}
LOGFILE_NAME=${SCRIPT_NAME_NO_EXT}".log"
LOGFILE=${SCRIPT_DIR}"/"${LOGFILE_NAME}
FECHA=$(date +"%Y%m%d_%H%M")
SISTEMA=$(uname -s)
USERNAME=$(whoami)

FECHA_LOG=$(date +"%Y%m%d")
LOGFILE="${SCRIPT_DIR}/${SCRIPT_NAME_NO_EXT}_${FECHA_LOG}.log"

# Color vars
BLKB=$'\e[40m'; RED=$'\e[31m'; GRN=$'\e[32m'; YEL=$'\e[33m'; BLU=$'\e[34m'; MAG=$'\e[35m'
CYN=$'\e[36m'; BOLD=$'\e[1m'; SALTO=$'\n'; TAB=$'\t'; BLK=$'\e[30m'; END=$'\e[0m'

# ???? Orange ???? $'\e[38;5;82m'
export PATH=/usr/bin/:$PATH

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4
