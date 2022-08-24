#/usr/bin/env bash

################################################################
##
## Shell script to archive config and upload to S3 bucket.
##
#################################################################


S3_BUCKET_NAME=""
DIR_TO_BACKUP="/home/wguser/wireguard/linguard/data/"
BACKUP_PREFIX='backup_'

TODAY=`date +%Y-%m-%d`
YY=`date +%Y`
MM=`date +%m`
AWSCMD="/usr/local/bin/aws"
TARCMD="/usr/bin/tar"

${TARCMD} czf /tmp/${BACKUP_PREFIX}-${TODAY}.tar.gz
${AWSCMD} cp /tmp/${BACKUP_PREFIX}-${TODAY}.tar.gz s3://${S3_BUCKET_NAME}/${YY}/${MM}/


if [ $? -eq 0 ]; then
 echo "Backup successfully uploaded to s3 bucket"
else
    echo "Error in s3 backup"
fi
