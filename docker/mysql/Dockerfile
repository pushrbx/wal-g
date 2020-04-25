FROM wal-g/ubuntu:latest

# mb not another path
ENV MYSQLDATA /var/lib/mysql

RUN apt-get update && \
    apt-get install --yes software-properties-common && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 && \
    add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.mephi.ru/mariadb/repo/10.3/ubuntu bionic main' && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes \
    curl \
    mariadb-server \
    mariadb-client \
    mariadb-backup


RUN curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | bash && apt -y install sysbench
RUN rm -rf $MYSQLDATA

COPY docker/mysql/client.cnf /root/.my.cnf
COPY docker/mysql/client.cnf /etc/mysql/debian.cnf
COPY docker/mysql/init.sql /etc/mysql/init.sql
COPY docker/mysql/export_common.sh /usr/local/export_common.sh

# append
COPY docker/mysql/my.cnf /tmp/my.cnf
RUN cat /tmp/my.cnf >> /etc/mysql/my.cnf; rm /tmp/my.cnf
