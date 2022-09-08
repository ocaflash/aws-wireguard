#/bin/bash

POSTFIX_DATE=$(date +%Y-%m-%d_%H-%M-%S)
tar cvzf /tmp/"backup_$POSTFIX_DATE.tgz" --absolute-names /home/wguser/wireguard/linguard/data/*
aws s3 cp /tmp/"backup_$POSTFIX_DATE.tgz" s3://"${name_prefix}-backup-${project_uuid}"/`date +%Y`/`date +%m`/backup_$POSTFIX_DATE.tgz
sudo rm -R /tmp/backup_*.tgz
