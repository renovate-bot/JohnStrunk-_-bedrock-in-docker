#!/bin/bash
# Check if server is running
if ! screen -list | grep -q "bedrock"; then
  echo "Server is not currently running!"
else
  # Stop the server
  CountdownTime=$1
  while [ $CountdownTime -gt 0 ]; do
    if [ $CountdownTime -eq 1 ]; then
      screen -Rd bedrock -X stuff "say Stopping server in 60 seconds...$(printf '\r')"
      sleep 30 &
      wait $!
      screen -Rd bedrock -X stuff "say Stopping server in 30 seconds...$(printf '\r')"
      sleep 20 &
      wait $!
      screen -Rd bedrock -X stuff "say Stopping server in 10 seconds...$(printf '\r')"
      sleep 10 &
      wait $!
    else
      screen -Rd bedrock -X stuff "say Stopping server in $CountdownTime minutes...$(printf '\r')"
      sleep 60 &
      wait $!
    fi
    ((CountdownTime--))
    echo "Waiting for $CountdownTime more minutes ..."
  done
  echo "Stopping Minecraft server ..."
  screen -Rd bedrock -X stuff "say Stopping server (stop.sh called)...^M"
  screen -Rd bedrock -X stuff "stop^M"

  # Wait up to 60 seconds for server to close
  Its=0
  while [ $Its -lt 60 ]; do
    if ! screen -list | grep -q "bedrock"; then
      break
    fi
    echo "Wait for bedrock until forcing stop ( $Its seconds)."
    sleep 1 &
    wait $!
    Its=$((Its+1))
  done

  # Force quit if server is still open
  if screen -list | grep -q "bedrock"; then
    echo "Minecraft server still hasn't stopped after 60 seconds, closing screen manually"
    screen -S bedrock -X quit
  fi

  echo "Minecraft server minecraft stopped."
fi
