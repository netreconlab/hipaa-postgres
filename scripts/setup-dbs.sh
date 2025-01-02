#!/bin/bash

cat >> ${PGDATA}/postgresql.conf <<EOF
cron.database_name = '$POSTGRES_DB'
shared_preload_libraries = 'set-user, pg_stat_statements, pgaudit, pg_cron'
EOF

set -e
psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" <<-EOSQL
    CREATE USER ${PG_PARSE_USER} LOGIN CONNECTION LIMIT 100 ENCRYPTED PASSWORD '${PG_PARSE_PASSWORD}';
    CREATE DATABASE ${PG_PARSE_DB} OWNER ${PG_PARSE_USER};
    CREATE EXTENSION pg_cron;
    \c ${PG_PARSE_DB};
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS postgis_topology;
    CREATE EXTENSION IF NOT EXISTS pgrouting;
EOSQL

exec "$@"
