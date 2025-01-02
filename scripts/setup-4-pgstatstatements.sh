#!/bin/bash

cat >> ${PGDATA}/postgresql.conf <<EOF
track_activity_query_size = 2048 # Increase tracked query string size
pg_stat_statements.track = all   # Track all statements including nested
track_io_timing = on             # Capture read/write stats
EOF

set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE EXTENSION pg_stat_statements SCHEMA public;
EOSQL

exec "$@"
