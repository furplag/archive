# Install Oracle FDW to Oracle Linux (WiP)

## Install PostgreSQL

### install packages .
```terminal.bash
[root@gte8 ~]# dnf install -y oracle-epel-release-el8 \
  https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
[root@gte8 ~]# dnf config-manager --disable pgdg{96,10,11,12} -y
[root@gte8 ~]# dnf module disable postgresql
[root@gte8 ~]# dnf install postgresql13{,-contrib,-devel,-libs,-server} -y
```
### set Environments .
```terminal.bash
[root@gte8 ~]# cat <<_EOT_>/etc/profile.d/postgresql.sh
# /etc/profile.d/postgresql.sh
export PGDATA=/var/lib/pgsql/13/data
export PATH=/usr/pgsql-13/bin:\$PATH

_EOT_
[root@gte8 ~]# source /etc/profile
[root@gte8 ~]# ldconfig
```

### Initialization .
```terminal.bash
[root@gte8 ~]# su - postgres
[postgres@gte8 ~]$ initdb -E UTF8 --locale=C -A scram-sha-256 -W
[postgres@gte8 ~]$ exit
# ~~ Configure $PGDATA/postgresql.conf ~~
[root@gte8 ~]# systemctl start postgresql-13
[root@gte8 ~]# createuser -U postgres -W -l -P -D -R -S ${ROLE:-"test"} 
[root@gte8 ~]# createdb -U postgres -W -T template0 -E UTF8 -O ${ROLE:-"test"} ${DATABASE:-"test"}
[root@gte8 ~]# systemctl stop postgresql-13
[root@gte8 ~]# systemctl enable postgresql-13
```
## Install Oracle Instant Client
```terminal.bash
[root@gte8 ~]# dnf install -y oracle-instantclient-release-el8
[root@gte8 ~]# dnf install -y oracle-instantclient-{basic,devel,sqlplus,tools}
[root@gte8 ~]# cat <<_EOT_> /etc/profile.d/oracle-instantclient.sh
export ORACLE_HOME=/usr/lib/oracle/21/client64
export PATH=\$PATH:\$ORACLE_HOME/bin

_EOT_
[root@gte8 ~]# source /etc/profile
[root@gte8 ~]# ldconfig
[root@gte8 ~]# mkdir -p $ORACLE_HOME/network/admin
# ~~ put OCI Wallet files into $ORACLE_HOME/network/admin . ~~
[root@gte8 ~]# sqlplus ${OCI_USER:-"test"}@${OCI_SID:-"test_high"}
```

## Install Oracle FDW
```terminal.bash
[root@gte8 ~]# curl -LO https://github.com/laurenz/oracle_fdw/archive/refs/tags/ORACLE_FDW_${ORACLE_FDW_VERSION:-"2_3_0"}.tar.gz
[root@gte8 ~]# tar zxvf ORACLE_FDW_${ORACLE_FDW_VERSION:-"2_3_0"}.tar.gz -C /opt/.
[root@gte8 ~]# cd /opt/oracle_fdw-ORACLE_FDW_${ORACLE_FDW_VERSION:-"2_3_0"}/
[root@gte8 ~]# C_INCLUDE_PATH=/usr/include/oracle/21/client64 make
[root@gte8 ~]# C_INCLUDE_PATH=/usr/include/oracle/21/client64 make install
[root@gte8 ~]# systemctl start postgresql-13
```
