#!/bin/bash
echo "Checking if restoring state is necessary (or requested to force)"
if [ ! -d "/bedrock/worlds" ] || [ ! "$(ls -A /bedrock/worlds)" ] || [ -n "$BEDROCK_IN_DOCKER_RESTORE_SNAPSHOT" ]; then
  echo "Restoring state from backup"
  restic restore --verify --host "$(hostname)" --target / "$BEDROCK_IN_DOCKER_RESTORE_SNAPSHOT"
fi
