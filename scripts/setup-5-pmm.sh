#!/bin/bash

echo "local   all $PMM_USER   scram-sha-256" >> "$PGDATA/pg_hba.conf"

set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_PASSWORD" <<-EOSQL
    CREATE USER pmm WITH SUPERUSER ENCRYPTED PASSWORD '$PMM_PASSWORD';
EOSQL

exec "$@"
