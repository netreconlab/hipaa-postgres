FROM postgres:16-bullseye 

ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.4.3+dfsg-1.pgdg110+1
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
      postgresql-$PG_MAJOR-cron \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /docker-entrypoint-initdb.d

# Install additional scripts. These are run in abc order during initial start
COPY ./scripts/initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./scripts/setup-0-pgaudit.sh /docker-entrypoint-initdb.d/
COPY ./scripts/setup-1-pgBadger.sh /docker-entrypoint-initdb.d/
COPY ./scripts/setup-3-pg_repack.sh /docker-entrypoint-initdb.d/
COPY ./scripts/setup-4-pgstatstatements.sh /docker-entrypoint-initdb.d/
COPY ./scripts/setup-5-pmm.sh /docker-entrypoint-initdb.d/
COPY ./scripts/setup-dbs.sh /docker-entrypoint-initdb.d/

# Install scripts to be run after DB initialization
COPY ./scripts/update-postgis.sh /usr/local/bin/update-postgis.sh
COPY ./scripts/setup-parse-index.sh /usr/local/bin/setup-parse-index.sh

# Make all scripts executable
RUN chmod +x /docker-entrypoint-initdb.d/setup-0-pgaudit.sh \
      /docker-entrypoint-initdb.d/setup-1-pgBadger.sh \
      /docker-entrypoint-initdb.d/setup-3-pg_repack.sh \
      /docker-entrypoint-initdb.d/setup-4-pgstatstatements.sh \
      /docker-entrypoint-initdb.d/setup-5-pmm.sh \
      /docker-entrypoint-initdb.d/setup-dbs.sh \
      /usr/local/bin/setup-parse-index.sh

USER postgres
CMD ["postgres", "-c", "shared_preload_libraries=pgaudit"]
