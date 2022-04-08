#!/bin/bash

# vim: set et ts=2 sw=2 filetype=bash :

{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set -x; } &>/dev/null; }

[[ $EUID -ne 0 ]] && { echo "${0##*/} must be run as root or via sudo";exit 1; } || { true; }



#### Begin Postgresql setup
apt install postgresql postgresql-common postgresql-client postgresql-client-common

# Basic PostgreSQL setup
export PG_DBVER=$(psql -V|awk '{gsub(/\..*$/,"");print $3}')
export PG_DBHBA="/etc/postgresql/${PG_DBVER}/main/pg_hba.conf"
export PG_DBVER=$(psql -V|awk '{gsub(/\..*$/,"");print $3}')
export PG_DBHBA="/etc/postgresql/${PG_DBVER}/main/pg_hba.conf"
export PG_DBHOST='maas.ubuntu-show.me'
export PG_DBUSER=postgres
export PG_DBNAME=postgres PG_DBPORT=5432
export PG_DBSSL_CRT=/etc/ssl/certs/show-me_ca.crt
export PG_DBSSL_PEM=/etc/ssl/certs/show-me_host.crt
export PG_DBSSL_KEY=/etc/ssl/private/show-me_host.key
su - postgres -c "psql postgres -c \"ALTER SYSTEM SET ssl to 'on';\""
su - postgres -c "psql postgres -c \"ALTER SYSTEM SET ssl_ca_file to '${PG_DBSSL_CRT}';\""
su - postgres -c "psql postgres -c \"ALTER SYSTEM SET ssl_cert_file to '${PG_DBSSL_PEM}';\""
su - postgres -c "psql postgres -c \"ALTER SYSTEM SET ssl_key_file to '${PG_DBSSL_KEY}';\""
su - postgres -c "psql postgres -c \"ALTER SYSTEM SET listen_addresses to '*';\""
su - postgres -c "psql postgres -c \"ALTER SYSTEM SET max_connections to '500';\""
su - postgres -c "psql postgres -c \"ALTER SYSTEM SET max_prepared_transactions to '500';\""
su - postgres -c 'psql postgres -c "SELECT pg_reload_conf();"'
su - postgres -c 'psql -P pager=off  postgres -xtc "select name,setting from pg_settings where name SIMILAR TO '"'"'listen%|max%(con|prep)%|ssl|ssl_(ca|cert|key)%'"'"';"'
su - postgres -c 'psql postgres -c "SELECT pg_reload_conf();"'  


# PostgreSQL setup for Canonical Snap-Store-Proxy
export SSP_DBVER=$(psql -V|awk '{gsub(/\..*$/,"");print $3}')
export SSP_DBHBA="/etc/postgresql/${SSP_DBVER}/main/pg_hba.conf"
export SSP_DBHOST=maas.ubuntu-show.me
export SSP_DBUSER=snap-proxy
export SSP_DBNAME='snap-proxy-db'
export SSP_DBPORT=5432
export SSP_DBPASS="$(env LANG=C LC_ALL=C tr 2>/dev/null -dc "[:alnum:]" < /dev/urandom|fold -w12|head -n1)"
export SSP_DBCON="postgres://${SSP_DBUSER}:${SSP_DBPASS}@${SSP_DBHOST}:${SSP_DBPORT}/${SSP_DBNAME}"
cat <<-SQL|su - postgres -c psql
CREATE ROLE "${SSP_DBUSER}" LOGIN CREATEROLE PASSWORD '${SSP_DBPASS}';
CREATE DATABASE "${SSP_DBNAME}" OWNER "${SSP_DBUSER}";
\connect "${SSP_DBNAME}"
CREATE EXTENSION "btree_gist";
SQL
echo "${SSP_DBHOST}:${SSP_DBPORT}:${SSP_DBNAME}:${SSP_DBUSER}:${SSP_DBPASS}"|su postgres -c 'tee 1>/dev/null /var/lib/postgresql/.pgpass.ssp'
chmod 0600 /var/lib/postgresql/.pgpass.ssp
chown postgres:postgres /var/lib/postgresql/.pgpass.ssp   
printf '%-08s%-016s%-016s%-024s%s\n' hostssl ${SSP_DBNAME} ${SSP_DBUSER} '::/0' md5 hostssl ${SSP_DBNAME} ${SSP_DBUSER} '0.0.0.0/0' md5|su - postgres -c 'tee -a '${SSP_DBHBA}''
su - postgres -c 'psql postgres -c "SELECT pg_reload_conf();"'

# PostgreSQL setup for Canonical Candid
export CANDID_DBVER=$(psql -V|awk '{gsub(/\..*$/,"");print $3}')
export CANDID_DBHBA="/etc/postgresql/${CANDID_DBVER}/main/pg_hba.conf"
export CANDID_DBHOST='maas.ubuntu-show.me'
export CANDID_DBUSER=candid
export CANDID_DBNAME='candiddb'
export CANDID_DBPORT=5432
export CANDID_DBPASS="$(env LANG=C LC_ALL=C tr 2>/dev/null -dc "[:alnum:]" < /dev/urandom|fold -w12|head -n1)"
export CANDID_DBCON="postgres://${CANDID_DBUSER}:${CANDID_DBPASS}@${CANDID_DBHOST}:${CANDID_DBPORT}/${CANDID_DBNAME}"
su - postgres -c 'psql -c "CREATE ROLE '${CANDID_DBUSER}' WITH SUPERUSER CREATEDB CREATEROLE LOGIN REPLICATION ENCRYPTED PASSWORD '"'"''${CANDID_DBPASS}''"'"';"'
su - postgres -c 'psql -c "CREATE DATABASE '${CANDID_DBNAME}' WITH OWNER '"'"''${CANDID_DBUSER}''"'"';"'
echo "${CANDID_DBHOST}:${CANDID_DBPORT}:${CANDID_DBNAME}:${CANDID_DBUSER}:${CANDID_DBPASS}"|su postgres -c 'tee 1>/dev/null /var/lib/postgresql/.pgpass.candid'
chmod 0600 /var/lib/postgresql/.pgpass.candid
chown postgres:postgres /var/lib/postgresql/.pgpass.candid 
printf '%-08s%-016s%-016s%-024s%s\n' hostssl ${CANDID_DBNAME} ${CANDID_DBUSER} '::/0' md5 hostssl ${CANDID_DBNAME} ${CANDID_DBUSER} '0.0.0.0/0' md5|su - postgres -c 'tee -a '${CANDID_DBHBA}''
su - postgres -c 'psql postgres -c "SELECT pg_reload_conf();"'

# PostgreSQL setup for Landscape
export LANDSCAPE_DBVER=$(psql -V|awk '{gsub(/\..*$/,"");print $3}')
export LANDSCAPE_DBHBA="/etc/postgresql/${LANDSCAPE_DBVER}/main/pg_hba.conf"
export LANDSCAPE_DBHOST='maas.ubuntu-show.me'
export LANDSCAPE_DBUSER=landscape
export LANDSCAPE_DBNAME='landscapedb'
export LANDSCAPE_DBPORT=5432
export LANDSCAPE_DBPASS="$(env LANG=C LC_ALL=C tr 2>/dev/null -dc "[:alnum:]" < /dev/urandom|fold -w12|head -n1)"
export LANDSCAPE_DBCON="postgres://${LANDSCAPE_DBUSER}:${LANDSCAPE_DBPASS}@${LANDSCAPE_DBHOST}:${LANDSCAPE_DBPORT}/${LANDSCAPE_DBNAME}"
su - postgres -c 'psql -c "CREATE ROLE '${LANDSCAPE_DBUSER}' WITH SUPERUSER CREATEDB CREATEROLE LOGIN REPLICATION ENCRYPTED PASSWORD '"'"''${LANDSCAPE_DBPASS}''"'"';"'
su - postgres -c 'psql -c "CREATE DATABASE '${LANDSCAPE_DBNAME}' WITH OWNER '"'"''${LANDSCAPE_DBUSER}''"'"';"'
echo "${LANDSCAPE_DBHOST}:${LANDSCAPE_DBPORT}:${LANDSCAPE_DBNAME}:${LANDSCAPE_DBUSER}:${LANDSCAPE_DBPASS}"|su postgres -c 'tee 1>/dev/null /var/lib/postgresql/.pgpass.landscape'
chmod 0600 /var/lib/postgresql/.pgpass.landscape
chown postgres:postgres /var/lib/postgresql/.pgpass.landscape
printf '%-08s%-016s%-016s%-024s%s\n' hostssl ${LANDSCAPE_DBNAME} ${LANDSCAPE_DBUSER} '::/0' md5 hostssl ${LANDSCAPE_DBNAME} ${LANDSCAPE_DBUSER} '0.0.0.0/0' md5|su - postgres -c 'tee -a '${LANDSCAPE_DBHBA}'' 
su - postgres -c 'psql postgres -c "SELECT pg_reload_conf();"'

# PostgreSQL setup for Canonical RBAC
export RBAC_DBVER=$(psql -V|awk '{gsub(/\..*$/,"");print $3}')
export RBAC_DBHBA="/etc/postgresql/${RBAC_DBVER}/main/pg_hba.conf"
export RBAC_DBHOST='maas.ubuntu-show.me'
export RBAC_DBUSER=rbac
export RBAC_DBNAME='rbacdb'
export RBAC_DBPORT=5432
export RBAC_DBPASS="$(env LANG=C LC_ALL=C tr 2>/dev/null -dc "[:alnum:]" < /dev/urandom|fold -w12|head -n1)"
export RBAC_DBCON="postgres://${RBAC_DBUSER}:${RBAC_DBPASS}@${RBAC_DBHOST}:${RBAC_DBPORT}/${RBAC_DBNAME}"
su - postgres -c 'psql -c "CREATE ROLE '${RBAC_DBUSER}' WITH SUPERUSER CREATEDB CREATEROLE LOGIN REPLICATION ENCRYPTED PASSWORD '"'"''${RBAC_DBPASS}''"'"';"'
su - postgres -c 'psql -c "CREATE DATABASE '${RBAC_DBNAME}' WITH OWNER '"'"''${RBAC_DBUSER}''"'"';"'
echo "${RBAC_DBHOST}:${RBAC_DBPORT}:${RBAC_DBNAME}:${RBAC_DBUSER}:${RBAC_DBPASS}"|su postgres -c 'tee 1>/dev/null /var/lib/postgresql/.pgpass.rbac'
printf '%-08s%-016s%-016s%-024s%s\n' hostssl ${RBAC_DBNAME} ${RBAC_DBUSER} '::/0' md5 hostssl ${RBAC_DBNAME} ${RBAC_DBUSER} '0.0.0.0/0' md5|su - postgres -c 'tee -a '${RBAC_DBHBA}''
su - postgres -c 'psql postgres -c "SELECT pg_reload_conf();"'

# PostgreSQL setup for Canonical MAAS
export MAAS_DBVER=$(psql -V|awk '{gsub(/\..*$/,"");print $3}')
export MAAS_PROFILE="maas-admin"
export MAAS_PASSWORD="ubuntu"
export MAAS_URIPORT=5240
export MAAS_FQDN='maas.ubuntu-show.me'
export MAAS_EMAIL='maas-admin@ubuntu-show.me'
export MAAS_IMPORTID='lp:craig-bender'
export MAAS_DBVER=$(psql -V|awk '{gsub(/\..*$/,"");print $3}')
export MAAS_DBHBA="/etc/postgresql/${MAAS_DBVER}/main/pg_hba.conf"
export MAAS_DBHOST='maas.ubuntu-show.me'
export MAAS_DBUSER=maas MAAS_DBNAME='maasdb'
export MAAS_DBPORT=5432
export MAAS_DBPASS="$(env LANG=C LC_ALL=C tr 2>/dev/null -dc "[:alnum:]" < /dev/urandom|fold -w12|head -n1)"
export MAAS_DBCON="postgres://${MAAS_DBUSER}:${MAAS_DBPASS}@${MAAS_DBHOST}:${MAAS_DBPORT}/${MAAS_DBNAME}"
export MAAS_URL="http://${MAAS_FQDN}:${MAAS_URIPORT}/MAAS"
su - postgres -c 'psql -c "CREATE ROLE '${MAAS_DBUSER}' WITH SUPERUSER CREATEDB CREATEROLE LOGIN REPLICATION ENCRYPTED PASSWORD '"'"''${MAAS_DBPASS}''"'"';"'
su - postgres -c 'psql -c "CREATE DATABASE '${MAAS_DBNAME}' WITH OWNER '"'"''${MAAS_DBUSER}''"'"';"'
echo "${MAAS_DBHOST}:${MAAS_DBPORT}:${MAAS_DBNAME}:${MAAS_DBUSER}:${MAAS_DBPASS}"|su postgres -c 'tee 1>/dev/null /var/lib/postgresql/.pgpass.maas'
cp -a /var/lib/postgresql/.pgpass* /home/$(id -un 1000)/;chown -R "$(id -un 1000):$(id -un 1000)" /home/$(id -un 1000)/\.*
printf '%-08s%-016s%-016s%-024s%s\n' hostssl ${MAAS_DBNAME} ${MAAS_DBUSER} '::/0' md5 hostssl ${MAAS_DBNAME} ${MAAS_DBUSER} '0.0.0.0/0' md5|su - postgres -c 'tee -a '${MAAS_DBHBA}''
su - postgres -c 'psql postgres -c "SELECT pg_reload_conf();"'
for P in MAAS SSP RBAC CANDID LANDSCAPE PG SHOW_ME;do set|grep "^${P}_";done|sort -uV|tee ~/.show-me.rc|su - $(id -un 1000) -c 'tee ~/.show-me.rc'|su - postgres -c 'tee ~/.show-me.rc'
echo 'for RC in $(find ~/ -maxdepth 1 -type f -iname ".show-me*.rc");do source $RC;done'|tee -a /root/.bashrc |su - $(id -un 1000) -c 'tee -a ~/.bashrc'|su - postgres -c 'tee -a ~/.bashrc'
#### END of Postgresql section

exit 0
{ [[ $CLOUD_DEBUG ]] &>/dev/null; } && { { set +x; } &>/dev/null; }
