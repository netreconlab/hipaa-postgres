# hipaa-postgres

[![](https://dockeri.co/image/netreconlab/hipaa-postgres)](https://hub.docker.com/r/netreconlab/hipaa-postgres)
[![Docker](https://github.com/netreconlab/hipaa-postgres/actions/workflows/build.yml/badge.svg)](https://github.com/netreconlab/hipaa-postgres/actions/workflows/build.yml)
[![Docker](https://github.com/netreconlab/hipaa-postgres/actions/workflows/release.yml/badge.svg)](https://github.com/netreconlab/hipaa-postgres/actions/workflows/release.yml)

---

A HIPAA & GDPR compliant ready Postgres Database image with PostGIS and PGAudit. Designed for [parse-hipaa](https://github.com/netreconlab/parse-hipaa) but can be used anywhere Postgres is used. These docker images include the necessary database auditing and logging for HIPAA compliance. `hipaa-postgres` is derived from [postgis](https://hub.docker.com/r/postgis/postgis) which is an extention built on top of the [official postgres image](https://hub.docker.com/_/postgres).

hipaa-postgres provides the following:
- [x] Auditing & logging
- [x] Ready for encryption in transit - run behind a proxy with files & directions on how to [complete the process](https://github.com/netreconlab/parse-hipaa#deploying-on-a-real-system) with Nginx and LetsEncrypt 

You will still need to setup the following on your own to be fully HIPAA compliant:

- [ ] Encryption in transit - you will need to [complete the process](https://github.com/netreconlab/parse-hipaa#deploying-on-a-real-system)
- [ ] Encryption at rest - Mount to your own encrypted storage drive (Linux and macOS have API's for this) and store the drive in a "safe" location
- [ ] Be sure to do anything else HIPAA requires

The [CareKitSample-ParseCareKit](https://github.com/netreconlab/CareKitSample-ParseCareKit) app uses this image alongise parse-hipaa and [ParseCareKit](https://github.com/netreconlab/ParseCareKit). If you are looking for a Mongo variant, checkout [hipaa-mongo](https://github.com/netreconlab/hipaa-mongo).

**Use at your own risk. There is not promise that this is HIPAA compliant and we are not responsible for any mishandling of your data**

## Images
Multiple images are automatically built for your convenience. Images can be found at the following locations:
- [Docker - Hosted on Docker Hub](https://hub.docker.com/r/netreconlab/hipaa-postgres)
- [Singularity - Hosted on GitHub Container Registry](https://github.com/netreconlab/hipaa-postgres/pkgs/container/hipaa-postgres)

## Additional Packages inside of hipaa-postgres that are enabled automatically
The following are enabled automatically on either the `PG_PARSE_DB` or `postgres` databases:
- [PostGIS](https://postgis.net) - spatial database extender for PostgreSQL object-relational database
- [pgAudit](https://www.pgaudit.org) - provide the tools needed to produce audit logs required to pass certain government, financial, or ISO certification audits
- [pgAudit-set_user](https://github.com/pgaudit/set_user) - allows switching users and optional privilege escalation with enhanced logging and control
- [pgBackrest](https://pgbackrest.org) - eliable, easy-to-use backup and restore solution that can seamlessly scale up to the largest databases and workloads by utilizing algorithms that are optimized for database-specific requirements
- [pg_repack](https://reorg.github.io/pg_repack/) - Reorganize tables in PostgreSQL databases with minimal locks
- [pgBadger](https://pgbadger.darold.net) - log analyzer built for speed with fully detailed reports and professional rendering
- [pgstatstatements](https://www.postgresql.org/docs/current/pgstatstatements.html) - provides a means for tracking planning and execution statistics of all SQL statements executed by a server (needed for PMM)
- [Percona Monitoring and Management (PMM)](https://www.percona.com/software/database-tools/percona-monitoring-and-management) - Monitor the health of your database infrastructure, explore new patterns in database behavior, and manage and improve the performance of your databases no matter where they are located or deployed
    - Username/passed - admin/admin
    - Goto `Settings->Add Instance to PMM->PostgreSQL`, enter `db` for hostname and the `Username` and `Password` above, then click `Add service`. Note it can take up to 5 minutes for data to start populating. PMM will let you know if it has trouble connecting. You should immediately see that PMM is able to read your database `version` correctly on its dashboard
    - Learn more about PMM by looking through the [documentation](https://docs.percona.com/percona-monitoring-and-management/index.html)

## Environment Variables

```
POSTGRES_PASSWORD # Password for postgress db cluster (Be sure to changes this in real deployments)
PG_PARSE_USER # Username for logging into PG_PARSE_DB (Be sure to changes this in real deployments)
PG_PARSE_PASSWORD # Password for logging into PG_PARSE_DB (Be sure to changes this in real deployments)
PG_PARSE_DB # Name of parse-hipaa database
PMM_USER=pmm # Username for Percona Monitor Managemet (Be sure to changes this in real deployments)
PMM_PASSWORD=pmm # Password for Percona Monitor Managemet (Be sure to changes this in real deployments)
PMM_PORT=80 # This is the default port on the docker image
PMM_TLS_PORT=443 # This is the default TLS port on the docker image
```

## Starting up hipaa-postgres

To get started, the [docker-compose.yml] file provides an example of how to use `hipaa-postgres`, simply type:

```docker-compose up```

You can connect to - [Percona Monitoring and Management (PMM)](https://www.percona.com/software/database-tools/percona-monitoring-and-management) by going to `localhost:1080` in your browser

Imporant Note: On the very first run of hipaa-postgres needs time to setup and will not allow connections until it is ready. This is suppose to happen as time is needed to configure, initialize, install necessary extensions, and setup any default databases. Let it keep running and eventually you will see something like:

```db_1         | PostgreSQL init process complete; ready for start up.```

Afterwards, hipaa-postfgress will allow all connections. 

## Configuring
If you are plan on using hipaa-postgres in production. You should run the additional scripts to create the rest of the indexes for optimized queries.

The `setup-parse-index.sh` file is already in the container. You just have to run it.

1. Log into your docker container, type: ```docker exec -u postgres -ti parse-hipaa_db_1 bash```
2. Run the script, type: ```./parseScripts/setup-parse-index.h```

If you want to persist the data in the database, you can uncomment the volume lines in [docker-compose](https://github.com/netreconlab/parse-hipaa/blob/master/docker-compose.yml#L41)

Default values for environment variables: `POSTGRES_PASSWORD, PG_PARSE_USER, PG_PARSE_PASSWORD, PG_PARSE_DB` are provided in [docker-compose.yml](https://github.com/netreconlab/parse-hipaa/blob/master/docker-compose.yml) for quick local deployment. If you plan on using this image to deploy in production, you should definitely change `POSTGRES_PASSWORD, PG_PARSE_USER, PG_PARSE_PASSWORD`. Note that the postgres image provides a default user of "postgres" to configure the database cluster, you can change the password for the "postgres" user by changing `POSTGRES_PASSWORD`. There are plenty of [postgres environment variables](https://hub.docker.com/_/postgres) that can be modified. Environment variables should not be changed unles you are confident with configuring postgres or else you image may not work properly. Note that changes to the aforementioned paramaters will only take effect if you do them before the first build and run of the image. Afterwards, you will need to make all changes by connecting to the image typing:

```docker exec -u postgres -ti parse-hipaa_db_1 bash```

You can then make modifications using [psql](http://postgresguide.com/utilities/psql.html). Through psql, you can also add multiple databases and users to support a number of parse apps. Note that you will also need to add the respecting parse-server containers (copy parse container in the .yml and rename to your new app) along with the added app in [postgres-dashboard-config.json](https://github.com/netreconlab/parse-hipaa/blob/master/parse-dashboard-config.json).

## Deploying on a real system
The docker yml's here are intended to run behind a proxy that properly has ssl configured to encrypt data in transit. To create a proxy to parse-hipaa, nginx files are provided [here](https://github.com/netreconlab/parse-hipaa/tree/master/nginx/sites-enabled). Simply add the [sites-available](https://github.com/netreconlab/parse-hipaa/tree/master/nginx/sites-enabled) folder to your nginx directory and add the following to "http" in your nginx.conf:

```
http {
    include /usr/local/etc/nginx/sites-enabled/*.conf; #Add this line to end. This is for macOS, do whatever is appropriate on your system
}
```

Setup your free certificates using [LetsEncrypt](https://letsencrypt.org), follow the directions [here](https://www.nginx.com/blog/using-free-ssltls-certificates-from-lets-encrypt-with-nginx/). Be sure to change the certificate and key lines to point to correct location in [default-ssl.conf](https://github.com/netreconlab/parse-hipaa/blob/master/nginx/sites-enabled/default-ssl.conf).
