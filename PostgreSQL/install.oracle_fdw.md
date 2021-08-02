# Install Oracle FDW to Oracle Linux (WiP)
## Install PostgreSQL
```terminal.bash
[root@gte8 ~] dnf install -y oracle-epel-release-el8 \
  https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
[root@gte8 ~] dnf config-manager --disable pgdg{96,10,11,12} -y
[root@gte8 ~] dnf module disable postgresql
[root@gte8 ~] dnf install postgresql13{,-contrib,-devel,-libs,-server} -y
[root@gte8 ~] cat <<_EOT_>/etc/profile.d/postgresql.sh
# /etc/profile.d/postgresql.sh
export PGDATA=/var/lib/pgsql/13/data
export PATH=/usr/pgsql-13/bin:\$PATH

_EOT_
[root@gte8 ~] source /etc/profile
[root@gte8 ~] cat <<_EOT_>> $PGDATA/postgresql.conf
include_dir='$PGDATA/postgresql.conf.d'

_EOT_
[root@gte8 ~] mkdir -p $PGDATA/postgresql.conf.d
[root@gte8 ~] cat <<_EOT_>> $PGDATA/postgresql.conf.d/00.base.conf
listen_addresses = '*'
post = 65432

# DB Version: 13
# OS Type: linux
# DB Type: web
# Total Memory (RAM): 2 GB
# CPUs num: 1
# Data Storage: ssd

max_connections = 200
shared_buffers = 512MB
effective_cache_size = 1536MB
maintenance_work_mem = 128MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 1310kB
min_wal_size = 1GB
max_wal_size = 4GB

_EOT_
[root@gte8 ~] 
```

## Install Oracle Instant Client

## Install Oracle FDW
