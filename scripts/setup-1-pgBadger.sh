#!/bin/bash

cat >> ${PGDATA}/postgresql.conf <<EOF
log_min_duration_statement = 0
log_line_prefix = '%t [%p]: '
log_checkpoints = on
log_disconnections = on
log_lock_waits = on
log_temp_files = 0
log_autovacuum_min_duration = 0
log_error_verbosity = default
EOF

exec "$@"
