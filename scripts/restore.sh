#!/bin/bash
# Restore backup if worlds directory not exists, is empty or BEDROCK_IN_DOCKER_FORCE_RESTORE if set to 1
if [ ! -d "/bedrock/worlds" ] || [ ! "$(ls -A /bedrock/worlds)" ] || [ ! -z "$BEDROCK_IN_DOCKER_FORCE_RESTORE" ]  && [ "$BEDROCK_IN_DOCKER_FORCE_RESTORE" == '1' ]; then
  if [ -f "/backups/latest.tar.gz" ]; then
      echo "Restoring latest backup (from /backups folder)"
      tar -xzvf /backups/latest.tar.gz
  else
      echo "Latest backup (latest.tar.gz) NOT found in /backups folder!!!. Restoring failed."
  fi
fi
