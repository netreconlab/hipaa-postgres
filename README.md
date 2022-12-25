# hipaa-postgres

[![](https://dockeri.co/image/netreconlab/hipaa-postgres)](https://hub.docker.com/r/netreconlab/hipaa-postgres)
[![Docker](https://github.com/netreconlab/hipaa-postgres/actions/workflows/build.yml/badge.svg)](https://github.com/netreconlab/hipaa-postgres/actions/workflows/build.yml)
[![Docker](https://github.com/netreconlab/hipaa-postgres/actions/workflows/release.yml/badge.svg)](https://github.com/netreconlab/hipaa-postgres/actions/workflows/release.yml)

---

A simple Postgres image built with PostGIS and PGAudit. Designed for [parse-hipaa](https://github.com/netreconlab/parse-hipaa) but can be used anywhere Postgres as used. These docker images include the necessary database auditing and logging for HIPAA compliance. hipaa-postgres is derived from [postgis](https://hub.docker.com/r/postgis/postgis) which is an extention built on top of the [official postgres image](https://hub.docker.com/_/postgres).

The parse-hipaa repo provides the following:
- [x] Auditing & logging
- [x] Ready for encryption in transit - run behind a proxy with files & directions on how to [complete the process](https://github.com/netreconlab/parse-hipaa#deploying-on-a-real-system) with Nginx and LetsEncrypt 

You will still need to setup the following on your own to be fully HIPAA compliant:

- [ ] Encryption in transit - you will need to [complete the process](https://github.com/netreconlab/parse-hipaa#deploying-on-a-real-system)
- [ ] Encryption at rest - Mount to your own encrypted storage drive (Linux and macOS have API's for this) and store the drive in a "safe" location
- [ ] Be sure to do anything else HIPAA requires

The [CareKitSample-ParseCareKit](https://github.com/netreconlab/CareKitSample-ParseCareKit) app uses this image alongise parse-hipaa and [ParseCareKit](https://github.com/netreconlab/ParseCareKit).

You can learn more about configuring hipaa-postgres [here]().

**Use at your own risk. There is not promise that this is HIPAA compliant and we are not responsible for any mishandling of your data**

## Images
Images of parse-hipaa are automatically built for your convenience. Images can be found at the following locations:
- [Docker - Hosted on Docker Hub](https://hub.docker.com/r/netreconlab/hipaa-postgres)
- [Singularity - Hosted on GitHub Container Registry](https://github.com/netreconlab/hipaa-postgres/pkgs/container/hipaa-postgres)

### Environment Variables

#### netreconlab/hipaa-postgres
```
POSTGRES_PASSWORD #Password for postgress db cluster
PG_PARSE_USER #Username for logging into PG_PARSE_DB
PG_PARSE_PASSWORD #Password for logging into PG_PARSE_DB
PG_PARSE_DB #Name of parse-hipaa database
```

### Starting up hipaa-postgres

Imporant Note: On the very first run of hipaa-postgres needs time to setup and will not allow connections until it is ready. This is suppose to happen as time is needed to configure, initialize, install necessary extensions, and setup any default databases. Let it keep running and eventually you will see something like:

```db_1         | PostgreSQL init process complete; ready for start up.```

Afterwards, hipaa-postfgress will allow all connections. 

### Congiguring
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
