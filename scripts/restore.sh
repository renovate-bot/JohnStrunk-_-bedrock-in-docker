#!/bin/bash
echo "Checking if restoring state is necessary (or requested to force)"
if [ ! -d "/bedrock/worlds" ] || [ ! "$(ls -A /bedrock/worlds)" ] || ( [ ! -z "$BEDROCK_IN_DOCKER_FORCE_RESTORE" ]  && [ "$BEDROCK_IN_DOCKER_FORCE_RESTORE" == '1' ] )
then
  if [ ! -z "$BEDROCK_IN_DOCKER_BACKUP_s3_URI" ]
  then
    echo "Restoring latest backup (from $BEDROCK_IN_DOCKER_BACKUP_s3_URI/latest.tar.gz)"
    aws s3 cp  $BEDROCK_IN_DOCKER_BACKUP_s3_URI/latest.tar.gz /backups/
  fi
  if [ -f "/backups/latest.tar.gz" ]; then
      echo "Restoring latest backup (from /backups folder)"
      tar -xzvf /backups/latest.tar.gz
      chown -R bedrock:bedrock ./
  else
      echo "Latest backup (latest.tar.gz) NOT found in /backups folder!!!. Restoring failed."
  fi
fi

echo "Checking config restore is necessary (or requested to force)"
if [ ! -z "$BEDROCK_IN_DOCKER_CONFIG_s3_URI" ]
then
  echo "Restoring latest config (from $BEDROCK_IN_DOCKER_CONFIG_s3_URI/)"
  aws s3 sync  $BEDROCK_IN_DOCKER_CONFIG_s3_URI/ . --exclude "*" --include "server.properties" --include "permissions.json" --include "whitelist.json"
fi
