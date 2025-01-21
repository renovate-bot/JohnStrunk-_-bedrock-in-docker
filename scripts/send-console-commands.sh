#!/bin/bash

# Check if server is running
if ! screen -list "bedrock"; then
  echo "Server is not currently running!"
  exit
fi

# If no list of commands is provided, exit
if [ ! -f /console-commands.txt ]; then
  echo "No console commands file found."
  exit
fi

# Send a console command to the server
function send-server {
  screen -Rd bedrock -X stuff "$1$(printf '\r')"
}

# Read the commands from the file and send them to the server
while IFS= read -r command; do
  send-server "$command"
done < /console-commands.txt
