#!/bin/bash

USER_AGENT="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)"

# Test internet connectivity first
if ! wget --quiet -U "$USER_AGENT" --timeout=30 http://www.minecraft.net/ -O /dev/null; then
    echo "Unable to connect to update website (internet connection may be down).  Skipping update ..."
else
    if [ "$BEDROCK_DOWNLOAD_URL" ]; then
      # Use specified version
      DownloadURL="$BEDROCK_DOWNLOAD_URL"
    else
      # Download server index.html to check latest version
      wget --no-verbose -U "$USER_AGENT" --timeout=30 -O /downloads/version.html https://minecraft.net/en-us/download/server/bedrock/
      DownloadURL=$(grep -o 'https://www.minecraft.net/bedrockdedicatedserver/bin-linux/[^"]*' /downloads/version.html)
    fi
    # shellcheck disable=SC2001
    DownloadFile=$(echo "$DownloadURL" | sed 's#.*/##')

    # Download latest version of Minecraft Bedrock dedicated server if a new one is available
    if [ -f "/downloads/$DownloadFile" ]
    then
        echo "Minecraft Bedrock server is up to date..."
    else
        echo "New version $DownloadFile is available.  Updating Minecraft Bedrock server ..."
        #rm -f /downloads/*
        wget --no-verbose -U "$USER_AGENT" -O "/downloads/$DownloadFile" "$DownloadURL"
    fi
    if [ -f "/bedrock/server.properties" ]
    then
      unzip -q -o "/downloads/$DownloadFile" -x "*server.properties*" "*permissions.json*" "*allowlist.json*" "*whitelist.json*" -d /bedrock/
    else
      unzip -q -o "/downloads/$DownloadFile" -d /bedrock/
    fi
    chmod a+x /bedrock/bedrock_server
fi
