#!/bin/bash

cat >> ${PGDATA}/postgresql.conf <<EOF
wal_level = logical
EOF

exec "$@"
