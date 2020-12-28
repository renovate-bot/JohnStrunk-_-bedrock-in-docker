#!/bin/bash
# Create backup
if [ -d "/bedrock/worlds" ]; then
    echo "Backing up server (to /backups folder)"
    tar -pzvcf /backups/latest.tar.gz worlds
    cp /backups/latest.tar.gz /backups/$(date +%Y.%m.%d.%H.%M.%S).tar.gz
    #[ ! -z "$MINECRAFTBE_s3_URI" ] && aws s3 mv backups $MINECRAFTBE_s3_URI --recursive --storage-class STANDARD_IA
fi
