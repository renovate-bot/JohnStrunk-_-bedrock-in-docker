#!/bin/bash
# Graceful exit bedrock instance
/scripts/stop.sh "$1" || true
/scripts/backup.sh || true
