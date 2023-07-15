#!/bin/bash
if [ "$1" = 'bedrock_server' ]; then
  MaxGracefulTime=${BEDROCK_IN_DOCKER_TERM_MIN:-1}
  trap '{ echo "recive SIGTERM. Going to stop bedrock immediately."; /scripts/terminate.sh 0 || true; exit 0; }' SIGTERM
  trap '{ echo "recive SIGQUIT. Going to stop bedrock in $MaxGracefulTime minute(s)."; /scripts/terminate.sh $MaxGracefulTime || true; exit 0; }' SIGQUIT

  echo 'Starting bedrock-in-docker deamon...'
  rm -f /bedrock/bedrock_screen.log
  tail -f --retry --sleep-interval=1 --max-unchanged-stats=300 /bedrock/bedrock_screen.log 2> /dev/null &
  screen -wipe

  /scripts/stop.sh 0 || true
  /scripts/restore.sh || true

  while true
  do
    MaxGracefulTime=${BEDROCK_IN_DOCKER_TERM_MIN:-1}

    (
      /scripts/terminate.sh "$MaxGracefulTime" || true
      /scripts/update.sh || true

      echo 'Configuring server properties'
      /scripts/configure-server.sh

      if ! screen -list bedrock; then
        screen -d -m -S bedrock -L -Logfile /bedrock/bedrock_screen.log bash -c "/scripts/start.sh"
      else
        echo 'FATAL: Unexpected screen bedrock already there'
      fi
    ) || echo 'Some error occured'

    RestartTime=${BEDROCK_IN_DOCKER_RESTART_TIME_UTC}
    current_epoch=$(date +%s)
    target_epoch=$(date -d $RestartTime +%s)

    sleep_seconds=$(( $target_epoch - $current_epoch ))
    if (( sleep_seconds <= 300 ))
    then
      sleep_seconds=$(( sleep_seconds + 86400))
    fi
    echo "Bedrock will run for next $sleep_seconds seconds"
    if [ "$BEDROCK_IN_DOCKER_FORCE_1_MIN_RESTART" == "1" ]
    then
      echo "Forcing 1min restarts."
      sleep_seconds=60
    fi
    sleep $sleep_seconds &
    wait $!
  done
fi
exec "$@"
