#!/bin/bash
if [[ -d "/bedrock/worlds" &&  -n $RESTIC_REPOSITORY ]]; then
  echo "Backup server (to restic)"
  restic backup --cleanup-cache \
    /bedrock/worlds \
    /bedrock/server.properties \
    /bedrock/permissions.json \
    /bedrock/allowlist.json
fi
