#!/bin/bash
# Create backup
if [ -d "/bedrock/worlds" ]
then
    echo "Backup server (to /backups folder)"
    tar -pzvcf /backups/latest.tar.gz worlds
    cp /backups/latest.tar.gz /backups/$(date +%Y.%m.%d.%H.%M.%S).tar.gz
    if [ ! -z "$BEDROCK_IN_DOCKER_BACKUP_s3_URI" ]
    then
      aws s3 mv /backups $BEDROCK_IN_DOCKER_BACKUP_s3_URI/ --recursive --exclude "latest.tar.gz" --storage-class STANDARD_IA
      aws s3 cp /backups/latest.tar.gz $BEDROCK_IN_DOCKER_BACKUP_s3_URI/latest.tar.gz --storage-class STANDARD_IA
    fi
fi

if [ ! -z "$BEDROCK_IN_DOCKER_CONFIG_s3_URI" ]
then
  echo "Backup config to $BEDROCK_IN_DOCKER_CONFIG_s3_URI/"
  aws s3 sync . $BEDROCK_IN_DOCKER_CONFIG_s3_URI/ --exclude "*" --include "server.properties" --include "permissions.json" --include "whitelist.json"
fi
