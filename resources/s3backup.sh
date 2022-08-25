#/usr/bin/env bash

S3_BUCKET_NAME="wireguard-bucket-0889b211d49c601b"
DIR_TO_BACKUP="/home/wguser/wireguard/linguard/data/"
BACKUP_PREFIX='backup_'

TODAY=`date +%Y-%m-%d`
YY=`date +%Y`
MM=`date +%m`
AWSCMD="aws s3"
TARCMD="tar"

tar czf /tmp/${BACKUP_PREFIX}-${TODAY}.tar.gz --absolute-names ${DIR_TO_BACKUP}
aws s3 cp /tmp/${BACKUP_PREFIX}-${TODAY}.tar.gz s3://${S3_BUCKET_NAME}/${YY}/${MM}/${BACKUP_PREFIX}-${TODAY}.tar.gz


if [ $? -eq 0 ]; then
 echo "Backup successfully uploaded to s3 bucket"
else
    echo "Error in s3 backup"
fi
