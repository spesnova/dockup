# Dockup [![Docker Repository on Quay](https://quay.io/repository/spesnova/aws-cli/status "Docker Repository on Quay")](https://quay.io/repository/spesnova/aws-cli)
Docker image to backup/restore your Docker container volumes to AWS S3

Why the name? Docker + Backup = Dockup

This is a fork repository. You can see the original here: https://github.com/tutumcloud/dockup

## SUPPORTED TAGS

* `latest`
 * aws-cli 1.9.2

## HOW TO USE
### Backup
You have a container running with one or more volumes:

```
$ docker run -d --name mysql tutum/mysql
```

From executing a `$ docker inspect mysql` we see that this container has two volumes:

```
"Volumes": {
            "/etc/mysql": {},
            "/var/lib/mysql": {}
        }
```

Share these volumes between mysql container and dockup container with volume container:

```
# data contaienr
$ docker run \
    --name data \
    -v /etc/mysql \
    -v /var/lib/mysql \
    alpine:3.2 \
    /bin/sh

# mysql container
$ docker run \
    -d \
    --name \
    --volumes_from data \
    mysql \
    tutum/mysql

# dockup container
$ docker run \
    -d \
    --name backup \
    --env-file env.txt \
    --volumes-from data \
    quay.io/spesnova/dockup
```

The contents of `env.txt` being:

```
AWS_ACCESS_KEY_ID=<key_here>
AWS_SECRET_ACCESS_KEY=<secret_here>
AWS_DEFAULT_REGION=us-east-1
BACKUP_NAME=mysql
MAX_NUMBER_OF_BACKUPS=10
PATHS_TO_BACKUP=/etc/mysql /var/lib/mysql
S3_BUCKET_NAME=my-bucket
CRON_TIME=3 0-23/3 * * *
```

`dockup` will use your AWS credentials to create a new bucket with name as per the environment variable `S3_BUCKET_NAME`, or if not defined, using the default name `docker-backups.example.com`. The paths in `PATHS_TO_BACKUP` will be tarballed, gzipped, time-stamped and uploaded to the S3 bucket regularly. You can control the time when it will starts with `CRON_TIME`.

Then, you will be able to see the backups are on S3 with `aws s3 ls` command.

```bash
$ aws s3 ls s3://my-bucket/mysql/
2016-02-05 04:02:54    5190945 mysql.2016-02-05-04-02-51.tar.gz
2016-02-05 04:03:08    5190945 mysql.2016-02-05-04-03-05.tar.gz
2016-02-05 04:05:34    5190945 mysql.2016-02-05-04-05-31.tar.gz
2016-02-05 04:07:06    5190945 mysql.2016-02-05-04-07-03.tar.gz
2016-02-05 04:07:31    5190945 mysql.2016-02-05-04-07-28.tar.gz
```


### Restore
To perform a restore launch the container with the RESTORE variable set to `true`.

Launch `dockup` container with the following flags:

```
$ docker run \
    --name restore \
    --env-file env.txt \
    --volumes_from data \
    quay.io/spesnova/dockup restore
```

The contents of `env.txt` being:

```
AWS_ACCESS_KEY_ID=<key_here>
AWS_SECRET_ACCESS_KEY=<secret_here>
AWS_DEFAULT_REGION=us-east-1
BACKUP_NAME=mysql
MAX_NUMBER_OF_BACKUPS=10
PATHS_TO_BACKUP=/etc/mysql /var/lib/mysql
S3_BUCKET_NAME=my-bucket
```

Then you can run a container with restored volumes.

```
$ docker run \
    -d \
    --name mysql \
    --volumes_from data \
    tutum/mysql
```
