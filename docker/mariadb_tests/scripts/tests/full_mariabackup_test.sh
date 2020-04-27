#!/bin/sh
set -e -x

. /usr/local/export_common.sh

export WALE_S3_PREFIX=s3://mariadbfullmariabackupbucket


mysql_install_db > /dev/null

service mysql start || (cat /var/log/mysql/error.log && false)

sysbench --table-size=10 prepare

sysbench --time=5 run

mysql -e 'FLUSH LOGS'

mysqldump sbtest > /tmp/dump_before_backup

wal-g backup-push

mariadb_kill_and_clean_data

wal-g backup-fetch LATEST
rm -rf "${MYSQLDATA}"/*
mariabackup --move-back --target-dir=$MYSQL_PREPARE_DIR
chown -R mysql:mysql $MYSQLDATA

service mysql start || (cat /var/log/mysql/error.log && false)

mariadb_set_gtid_purged

mysqldump sbtest > /tmp/dump_after_restore

diff /tmp/dump_before_backup /tmp/dump_after_restore
