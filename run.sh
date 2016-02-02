#!/bin/sh

if [[ "$RESTORE" == "true" ]]; then
  sh /restore.sh
else
  sh /backup.sh
  echo "${CRON_TIME} sh /backup.sh" > /crontab.conf
  crontab  /crontab.conf
  echo "=> Running cron job"
  crond -l 0 -f
fi
