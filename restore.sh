#!/bin/bash

echo "=> Restore has been started"

# Find last backup file
: ${LAST_BACKUP:=$(aws s3 ls s3://$S3_BUCKET_NAME/$BACKUP_NAME/ | awk -F " " '{print $4}' | grep ^$BACKUP_NAME | sort -r | head -n1)}

# Stop to restore, if backup doesn't exist
if [ "$LAST_BACKUP" = "" ] ;
then
  echo "=> Skipped restoring because there was no backups on the S3"
  exit 0
fi

# Download backup from S3
echo "=> Downloading latest backup from S3: $LAST_BACKUP"
aws s3 cp s3://$S3_BUCKET_NAME/$BACKUP_NAME/$LAST_BACKUP $LAST_BACKUP

# Extract backup
echo "=> Extracting the backup: $LAST_BACKUP"
tar xzf $LAST_BACKUP $RESTORE_TAR_OPTION
for path in $PATHS_TO_BACKUP
do
  echo "=> Extracted contents: $path"
  ls -l $path
done

echo "=> Restore has been completed"
