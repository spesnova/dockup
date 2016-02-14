#!/bin/bash

echo "=> Backup has been started"

# Get timestamp
: ${BACKUP_SUFFIX:=.$(date +"%Y-%m-%d-%H-%M-%S")}
readonly tarball=/$BACKUP_NAME$BACKUP_SUFFIX.tar.gz

# Create a gzip compressed tarball with the volume(s)
echo "=> Creating compressed backup: $tarball"
tar czf $tarball $BACKUP_TAR_OPTION $PATHS_TO_BACKUP

# Create bucket, if it doesn't already exist
aws s3 ls s3://$S3_BUCKET_NAME >/dev/null 2>&1
if [ $? -ne 0 ];
then
  aws s3 mb s3://$S3_BUCKET_NAME
fi

# Upload the backup to S3 with timestamp
echo "=> Uploading the backup to S3: $tarball"
aws s3 --region $AWS_DEFAULT_REGION cp $tarball s3://$S3_BUCKET_NAME/$BACKUP_NAME/$tarball

# Dispose of old backups
if [[ -n "$MAX_NUMBER_OF_BACKUPS" ]]; then
  if [[ "$MAX_NUMBER_OF_BACKUPS" -gt 0 ]]; then
    backups=$(aws s3 ls s3://$S3_BUCKET_NAME/$BACKUP_NAME/ \
      | awk -F " " '{print $4}' \
      | grep ^$BACKUP_NAME \
      |  head -n -${MAX_NUMBER_OF_BACKUPS}
    )

    for backup in $backups
    do
      echo "=> Removing an old backup: s3://$S3_BUCKET_NAME/$BACKUP_NAME/$backup"
      aws s3 rm s3://$S3_BUCKET_NAME/$BACKUP_NAME/$backup
    done
  fi
fi

# Dispose of local backup
echo "=> Removing local backup: $tarball"
rm $tarball

echo "=> Backup has been completed"
