#!/bin/bash
if [[ -d "/bedrock/worlds" &&  -n $RESTIC_REPOSITORY ]]; then
  echo "Backup server (to restic)"
  restic backup --cleanup-cache \
    /bedrock/worlds \
    /bedrock/server.properties \
    /bedrock/permissions.json \
    /bedrock/allowlist.json

  echo "Forget old backups"
  restic forget --cleanup-cache \
    --keep-daily 14 \
    --keep-weekly 4 \
    --keep-monthly 12 \
    --keep-yearly 2 \
    --keep-tag keep
fi
