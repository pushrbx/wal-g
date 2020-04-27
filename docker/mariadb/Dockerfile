FROM wal-g/ubuntu:latest

# mb not another path
ENV MYSQLDATA /var/lib/mysql
ENV MYSQL_PREPARE_DIR /var/backups/mysql

# fixme: the package of MariaDB 10.4 doesn't work in this environement because it's not being added to the services.
RUN apt-get update && \
    apt-get install --yes --no-install-recommends --no-install-suggests software-properties-common dirmngr gnupg2 curl && \
    curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | /bin/bash -s -- --mariadb-server-version="mariadb-10.3" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes \
    mariadb-server \
    mariadb-client \
    mariadb-backup \
    percona-xtrabackup

RUN curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | bash && apt -y install sysbench
RUN rm -rf $MYSQLDATA && mkdir -p $MYSQL_PREPARE_DIR

COPY docker/mariadb/client.cnf /root/.my.cnf
COPY docker/mariadb/client.cnf /etc/mysql/debian.cnf
COPY docker/mariadb/init.sql /etc/mysql/init.sql
COPY docker/mariadb/export_common.sh /usr/local/export_common.sh
# we activate the binary log this way. Note: might not work for 10.4 in the future. https://mariadb.com/kb/en/activating-the-binary-log/
COPY docker/mariadb/custom_opts.conf /etc/systemd/system/mariadb.service.d/MY_SPECIAL.conf

# append
COPY docker/mariadb/my.cnf /tmp/my.cnf
RUN cat /tmp/my.cnf >> /etc/mysql/my.cnf; rm /tmp/my.cnf
