FROM quay.io/spesnova/aws-cli:latest
MAINTAINER Seigo Uchida <spesnova@gmail.com> (@spesnova)

ENV ENTRYKIT_VERSION 0.4.0
WORKDIR /

RUN apk-install openssl \
  && wget https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && tar -xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && mv entrykit /bin/entrykit \
  && chmod +x /bin/entrykit \
  && entrykit --symlink

COPY backup.sh /backup.sh
COPY restore.sh /restore.sh
COPY crontab.conf.tmpl /crontab.conf.tmpl
RUN chmod 755 /*.sh

ENV S3_BUCKET_NAME docker-backups.example.com
ENV BACKUP_NAME backup

ENTRYPOINT [ \
  "switch", \
    "backup=/bin/sh /backup.sh", \
    "restore=/bin/sh /restore.sh", \
    "shell=/bin/sh", "--", \
  "render", \
    "/crontab.conf", "--", \
  "prehook", \
    "/bin/sh /backup.sh", \
    "echo Running cron job...", \
    "/usr/bin/crontab /crontab.conf", "--", \
  "/usr/sbin/crond" \
]
CMD ["-l", "0", "-f"]
