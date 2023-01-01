FROM postgres:15-bullseye

ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.3.2+dfsg-1.pgdg110+1
ENV POSTGRES_INITDB_ARGS "--data-checksums"

RUN apt-get update \
 && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      elephant-shed-pgbackrest \
      elephant-shed-pgbadger \
      \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
      postgresql-$PG_MAJOR-pgaudit \
      postgresql-$PG_MAJOR-set-user \
      postgresql-$PG_MAJOR-repack \
      postgresql-$PG_MAJOR-wal2json \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /docker-entrypoint-initdb.d \
 && mkdir parseScripts

# Install scripts to be run after DB initialization
COPY ./scripts/initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./scripts/update-postgis.sh /usr/local/bin/update-postgis.sh
COPY ./scripts/setup-parse-index.sh ./parseScripts/setup-parse-index.sh

# Install additional scripts. These are run in abc order during initial start
COPY ./scripts/setup-0-pgaudit.sh /docker-entrypoint-initdb.d/
COPY ./scripts/setup-1-pgBadger.sh /docker-entrypoint-initdb.d/
COPY ./scripts/setup-2-wal2json.sh /docker-entrypoint-initdb.d/
COPY ./scripts/setup-3-pg_repack.sh /docker-entrypoint-initdb.d/
COPY ./scripts/setup-4-pgstatstatements.sh /docker-entrypoint-initdb.d/
COPY ./scripts/setup-5-pmm.sh /docker-entrypoint-initdb.d/
COPY ./scripts/setup-dbs.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/setup-0-pgaudit.sh \
      /docker-entrypoint-initdb.d/setup-1-pgBadger.sh \
      /docker-entrypoint-initdb.d/setup-2-wal2json.sh \
      /docker-entrypoint-initdb.d/setup-3-pg_repack.sh \
      /docker-entrypoint-initdb.d/setup-4-pgstatstatements.sh \
      /docker-entrypoint-initdb.d/setup-5-pmm.sh \
      /docker-entrypoint-initdb.d/setup-dbs.sh \
      ./parseScripts/setup-parse-index.sh

CMD ["postgres", "-c", "shared_preload_libraries=pgaudit"]
