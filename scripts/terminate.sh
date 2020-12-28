#!/bin/bash
# Graceful exit bedrock instance
/scripts/stop.sh $1 && /scripts/backup.sh
