# Dockup
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

Launch `dockup` container with the following flags:

```
$ docker run \
    -d \
    --name backup \
    --env-file env.txt \
    --volumes-from mysql \
    quay.io/spesnova/dockup
```

The contents of `env.txt` being:

```
AWS_ACCESS_KEY_ID=<key_here>
AWS_SECRET_ACCESS_KEY=<secret_here>
AWS_DEFAULT_REGION=us-east-1
BACKUP_NAME=mysql
PATHS_TO_BACKUP=/etc/mysql /var/lib/mysql
S3_BUCKET_NAME=docker-backups.example.com
CRON_TIME=3 0-23/3 * * *
```

`dockup` will use your AWS credentials to create a new bucket with name as per the environment variable `S3_BUCKET_NAME`, or if not defined, using the default name `docker-backups.example.com`. The paths in `PATHS_TO_BACKUP` will be tarballed, gzipped, time-stamped and uploaded to the S3 bucket regularly. You can control the time when it will starts with `CRON_TIME`.

Then, you will be able to see the backups at AWS Management Console.

![](http://s.tutum.co.s3.amazonaws.com/support/images/dockup-readme.png)

### Restore
To perform a restore launch the container with the RESTORE variable set to `true`.

Launch `dockup` container with the following flags:

```
$ docker run \
    --name restore \
    --env-file env.txt \
    -v /etc/mysql \
    -v /var/lib/mysql \
    quay.io/spesnova/dockup
```

The contents of `env.txt` being:

```
AWS_ACCESS_KEY_ID=<key_here>
AWS_SECRET_ACCESS_KEY=<secret_here>
AWS_DEFAULT_REGION=us-east-1
BACKUP_NAME=mysql
PATHS_TO_BACKUP=/etc/mysql /var/lib/mysql
S3_BUCKET_NAME=docker-backups.example.com
RESTORE=true
```

Then you can run a container with volumes from restore container.

```
$ docker run \
    -d \
    --name mysql \
    --volumes-from restore \
    tutum/mysql
```
