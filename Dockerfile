FROM perconalab/percona-distribution-postgresql:15.1

ENV PG_MAJOR 15
ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.3.2+dfsg-1.pgdg110+1
ENV PGDATA /var/lib/postgresql/data
ENV POSTGRES_INITDB_ARGS "--data-checksums"

USER root

#BAKER - Need to figure out how to install postgis
#RUN microdnf -y update; \
#      microdnf postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
#      microdnf install -y --no-install-recommends \
           # ca-certificates: for accessing remote raster files;
           #   fix: https://github.com/postgis/docker-postgis/issues/307
#           ca-certificates \
#           \
#           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
#           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
#           --setopt=install_weak_deps=0 \
#      microdnf clean all

#RUN mkdir -p /docker-entrypoint-initdb.d
#COPY ./scripts/initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
RUN mkdir -p /usr/local/bin
COPY ./scripts/update-postgis.sh /usr/local/bin

#Install additional scripts. These are run in abc order during initial start
COPY ./scripts/setup-0-pgaudit.sh /docker-entrypoint-initdb.d/setup-0-pgaudit.sh
COPY ./scripts/setup-1-pgBadger.sh /docker-entrypoint-initdb.d/setup-1-pgBadger.sh
COPY ./scripts/setup-2-wal2json.sh /docker-entrypoint-initdb.d/setup-2-wal2json.sh
COPY ./scripts/setup-3-pg_repack.sh /docker-entrypoint-initdb.d/setup-3-pg_repack.sh
#COPY ./scripts/setup-dbs.sh /docker-entrypoint-initdb.d/setup-dbs.sh
COPY ./scripts/setup-dbs-no-postgis.sh /docker-entrypoint-initdb.d/setup-dbs.sh
RUN chmod +x /docker-entrypoint-initdb.d/setup-0-pgaudit.sh \ 
      /docker-entrypoint-initdb.d/setup-1-pgBadger.sh \
      /docker-entrypoint-initdb.d/setup-2-wal2json.sh \
      /docker-entrypoint-initdb.d/setup-3-pg_repack.sh \
      /docker-entrypoint-initdb.d/setup-dbs.sh

#Install script for ParseCareKit to be run after first run
RUN mkdir parseScripts
COPY ./scripts/setup-parse-index.sh ./parseScripts/setup-parse-index.sh
RUN chmod +x ./parseScripts/setup-parse-index.sh

# Set user back to general user
USER 1001

CMD ["postgres", "-c", "shared_preload_libraries=pgaudit"]