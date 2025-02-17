#!/usr/bin/env bash

#!/usr/bin/env bash

[ "${TRACE}" != "" ] && set -x

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# GLOBAL MySQL Variables
get_mysql_params "${SCRIPT_DIR}/restore_metrics.json"

# Load metrics functions
source ${SCRIPT_DIR}/../library/metrics.sh

# Install Packets
apt update && apt install jq -y

# Create Restore Metrics Table Log
#DROP TABLE cuadro_mandos.restore_metrics;

mysql --host=${MYSQL_HOST} --port=${MYSQL_PORT} \
      --user=${MYSQL_USER} --password=${MYSQL_PASS} \
      -e "CREATE TABLE `restore_metrics` ( \
          `id` int NOT NULL AUTO_INCREMENT, \
          `file` varchar(255) NOT NULL, \
          `restoration_table` varchar(255) NOT NULL, \
          `restoration_date` varchar(255) NOT NULL, \
          `info` varchar(255) DEFAULT NULL, \
          `restore_date_init` datetime NOT NULL DEFAULT '2000-01-01 00:00:00', \
          `restore_date_end` datetime NOT NULL DEFAULT '2000-01-01 00:00:00', \
          PRIMARY KEY (`id`), \
          UNIQUE (`file`) \
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3"
mysql --host=${MYSQL_HOST} --port=${MYSQL_PORT} \
      --user=${MYSQL_USER} --password=${MYSQL_PASS} \
      -e "DESCRIBE cuadro_mandos.restore_metrics"

# Create Daemons
sudo cp *.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable restore_metrics.service
#sudo systemctl start restore_metrics.service
sudo systemctl enable restore_metrics_status.service
#sudo systemctl start restore_metrics_status.service
sudo systemctl daemon-reload

