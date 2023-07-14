#!/bin/bash
# Graceful exit bedrock instance
/scripts/stop.sh "$1" || true
/scripts/restore.sh || true
/scripts/backup.sh || true
