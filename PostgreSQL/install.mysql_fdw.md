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

## 🚨 cannot convert Emoji from PostgreSQL to MySQL 🤦‍♂️
[solution, for now](https://github.com/EnterpriseDB/mysql_fdw/issues/133)
> After an initial analysis, it seems like it is failing because of character-set issue.
> While making the connection to MySQL, we set character-set same as current Postgres database like below which is "UTF8" in our case:
> 
> mysql_options(conn, MYSQL_SET_CHARSET_NAME, GetDatabaseEncodingName());
> 
> but it seems like MySQL expects "utf8mb4" character set here so that the above emojis should be inserted and fetched correctly.
> After changing that value to hard-coded "utf8mb4", I am able to fetch and insert that emoji correctly.
> 
> e.g:
> mysql_options(conn, MYSQL_SET_CHARSET_NAME, "utf8mb4");
> 
> These changes are done in the mysql_connect() function which is in connection.c file.

1. define new option "character_set" in options .
2. and set character-set using ```mysql_options()```, if the option is specified .
```oracle_fdw.h
	/* oracle_fdw.h:115 */
	char     *character_set;    /* MySQL charcter set */
} mysql_opt;
```
```option.c
	/* option.c:59 */
	{"character_set", ForeignServerRelationId},
	/* Sentinel */
	{NULL, InvalidOid}
		if (strcmp(def->defname, "ssl_cipher") == 0)
			opt->ssl_cipher = defGetString(def);
	}
...
	/* option.c:263 */
		if (strcmp(def->defname, "character_set") == 0)
			opt->character_set = defGetString(def);
```
```connection.c
/* connection.c: 236 */
mysql_options(conn, MYSQL_SET_CHARSET_NAME, opt->character_set?:GetDatabaseEncodingName());
```
