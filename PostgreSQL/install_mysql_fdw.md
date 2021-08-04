# Install MySQL FDW to Oracle Linux (WiP)

## Install MySQL ( MariaDB )

### install packages .
```terminal.bash
[root@gte8 ~]# dnf install -y oracle-epel-release-el8
[root@gte8 ~]# dnf install mariadb{,-devel} -y
```

### Initialization .
```terminal.bash
# ~~ Configure /etc/my.cnf.d/server.cnf ~~
[root@gte8 ~]# systemctl start mariadb
[root@gte8 ~]# mysql_secure_installation
[root@gte8 ~]# systemctl stop mariadb
[root@gte8 ~]# systemctl enable mariadb
```

## Install MySQL FDW
```terminal.bash
[root@gte8 ~]# curl -LO https://github.com/EnterpriseDB/mysql_fdw/archive/refs/tags/${MYSQL_FDW_VERSION:-"REL-2_6_0"}.tar.gz
[root@gte8 ~]# tar zxvf ${MYSQL_FDW_VERSION:-"REL-2_6_0"}.tar.gz -C /opt/.
[root@gte8 ~]# cd /opt/mysql_fdw-${MYSQL_FDW_VERSION:-"REL-2_6_0"}
[root@gte8 ~]# make USE_PGXS=1
[root@gte8 ~]# make USE_PGXS=1 install
[root@gte8 ~]# systemctl start mariadb
```
