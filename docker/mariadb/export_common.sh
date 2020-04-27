#!/usr/bin/env bash

# common wal-g settings.
export WALG_MYSQL_DATASOURCE_NAME=sbtest:@/sbtest
export WALG_STREAM_CREATE_COMMAND="mariabackup --backup --stream=xbstream --user=sbtest --host=localhost --datadir=${MYSQLDATA}"
export WALG_STREAM_RESTORE_COMMAND="mbstream -x -C ${MYSQL_PREPARE_DIR}"
export WALG_MYSQL_BACKUP_PREPARE_COMMAND="mariabackup --prepare --target-dir=${MYSQL_PREPARE_DIR}"
export WALG_MYSQL_BINLOG_REPLAY_COMMAND='mysqlbinlog --stop-datetime="$WALG_MYSQL_BINLOG_END_TS" "$WALG_MYSQL_CURRENT_BINLOG" | mysql'
export WALG_MYSQL_BINLOG_DST=/tmp


# test tools
mariadb_kill_and_clean_data() {
    kill -9 `pidof mysqld` || true
    rm -rf "${MYSQLDATA}"/*
    rm -rf /root/.walg_mysql_binlogs_cache
}

mariadb_set_gtid_purged() {
    gtids=$(tr -d '\n' < ${MYSQL_PREPARE_DIR}/xtrabackup_binlog_info | awk '{print $3}')
    echo "Gtids from backup $gtids"
    # todo: figure out if we need to execute "CHANGE MASTER TO MASTER_USE_GTID = slave_pos;" or something similiar.
    mysql -e "RESET MASTER; SET GLOBAL gtid_slave_pos = \"${gtids}\"; CHANGE MASTER TO master_host=\"127.0.0.1\", master_port=3306, master_user=\"root\", MASTER_USE_GTID = slave_pos; START SLAVE;"
}

sysbench() {
    # shellcheck disable=SC2068
    /usr/bin/sysbench --db-driver=mysql --verbosity=0 /usr/share/sysbench/oltp_insert.lua $@
}

date3339() {
    date --rfc-3339=ns | sed 's/ /T/'
}
