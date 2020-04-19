#!/usr/bin/env bash

# common wal-g settings
export WALG_MARIADB_DATASOURCE_NAME=sbtest:@/sbtest
export WALG_STREAM_CREATE_COMMAND="mariabackup --backup \
    --stream=xbstream \
    --user=sbtest \
    --host=localhost \
    --parallel=2 \
    --datadir=${MYSQLDATA}"
export WALG_STREAM_RESTORE_COMMAND="mbstream -x -C ${MYSQLDATA}"
export WALG_MARIADB_BACKUP_PREPARE_COMMAND="mariabackup --prepare --target-dir=${MYSQLDATA}"
export WALG_MARIADB_BINLOG_REPLAY_COMMAND='mysqlbinlog --stop-datetime="$WALG_MARIADB_BINLOG_END_TS" "$WALG_MARIADB_CURRENT_BINLOG" | mysql'
export WALG_MARIADB_BINLOG_DST=/tmp


# test tools
mariadb_kill_and_clean_data() {
    service mysql stop
    rm -rf "${MYSQLDATA}"/*
    rm -rf /root/.walg_mysql_binlogs_cache
}

sysbench() {
    /usr/bin/sysbench --db-driver=mysql --verbosity=0 /usr/share/sysbench/oltp_insert.lua $@
}

date3339() {
    date --rfc-3339=ns | sed 's/ /T/'
}
