#!/bin/bash

set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    \c template1;
    CREATE EXTENSION pgrouting;
EOSQL

exec "$@"
