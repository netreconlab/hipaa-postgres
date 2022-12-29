FROM perconalab/percona-distribution-postgresql:15.1

ENV PG_MAJOR 15
ENV POSTGIS_VERSION 3.3
ENV PGDATA /var/lib/postgresql/data
ENV POSTGRES_INITDB_ARGS "--data-checksums"
ENV EPEL8_RPM "https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm"

USER root

#BAKER - Need to figure out how to install postgis
#RUN rpm -ivh ${EPEL8_RPM} \
#      sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/epel*.repo

#RUN microdnf -y --enablerepo="epel" --enablerepo="codeready-builder-for-rhel-8-x86_64-rpms" --nodocs install libaec libdap armadillo; \
#      microdnf -y install --nodocs \
#     	      --enablerepo="epel" \
#		pgrouting${POSTGIS_VERSION}_${PG_MAJOR//.} \
#		postgis${POSTGIS_VERSION}_${PG_MAJOR//.} \
#		postgis${POSTGIS_VERSION}_${PG_MAJOR//.}-client \
#		postgresql${PG_MAJOR//.}-plperl \
#		postgresql${PG_MAJOR//.}-pltcl; \
#	microdnf -y clean all --enablerepo="epel" --enablerepo="codeready-builder-for-rhel-8-x86_64-rpms"

#RUN mkdir -p /docker-entrypoint-initdb.d
#COPY ./scripts/initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
RUN mkdir -p /usr/local/bin
COPY ./scripts/update-postgis.sh /usr/local/bin

# Install additional scripts. These are run in abc order during initial start
COPY ./scripts/setup-0-pgaudit.sh /docker-entrypoint-initdb.d/setup-0-pgaudit.sh
COPY ./scripts/setup-1-pgBadger.sh /docker-entrypoint-initdb.d/setup-1-pgBadger.sh
COPY ./scripts/setup-2-wal2json.sh /docker-entrypoint-initdb.d/setup-2-wal2json.sh
COPY ./scripts/setup-3-pg_repack.sh /docker-entrypoint-initdb.d/setup-3-pg_repack.sh
COPY ./scripts/setup-4-pgstatstatements.sh /docker-entrypoint-initdb.d/setup-4-pgstatstatements.sh
COPY ./scripts/setup-5-pmm.sh /docker-entrypoint-initdb.d/setup-5-pmm.sh
COPY ./scripts/setup-dbs-no-postgis.sh /docker-entrypoint-initdb.d/setup-dbs.sh
RUN chmod +x /docker-entrypoint-initdb.d/setup-0-pgaudit.sh \ 
#COPY ./scripts/setup-dbs.sh /docker-entrypoint-initdb.d/setup-dbs.sh \
RUN chmod +x /docker-entrypoint-initdb.d/setup-0-pgaudit.sh \
      /docker-entrypoint-initdb.d/setup-1-pgBadger.sh \
      /docker-entrypoint-initdb.d/setup-2-wal2json.sh \
      /docker-entrypoint-initdb.d/setup-3-pg_repack.sh \
      /docker-entrypoint-initdb.d/setup-4-pgstatstatements.sh \
      /docker-entrypoint-initdb.d/setup-5-pmm.sh \
      /docker-entrypoint-initdb.d/setup-dbs.sh

# Install script for ParseCareKit to be run after first run
RUN mkdir parseScripts
COPY ./scripts/setup-parse-index.sh ./parseScripts/setup-parse-index.sh
RUN chmod +x ./parseScripts/setup-parse-index.sh

# Set user back to general user
USER 1001

CMD ["postgres", "-c", "shared_preload_libraries=pgaudit"]
