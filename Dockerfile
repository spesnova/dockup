FROM quay.io/spesnova/aws-cli:latest
MAINTAINER Seigo Uchida <spesnova@gmail.com> (@spesnova)

WORKDIR /

ADD backup.sh /backup.sh
ADD restore.sh /restore.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh

ENV S3_BUCKET_NAME docker-backups.example.com
ENV BACKUP_NAME backup
ENV RESTORE false

CMD ["/run.sh"]
