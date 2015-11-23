#!/usr/bin/env bash

. $RAILS_HOME/script/app_config.sh

bin=`readlink "$0"`
if [ "$bin" == "" ]; then
 bin=$0
fi
bin=`dirname "$bin"`
bin=`cd "$bin"; pwd`

MAX_WAIT_TIME=$1

log "Stopping MongoDB"

if [ -f $MONGODB_PID_FILE ]; then
  if kill -0 `cat $MONGODB_PID_FILE` > /dev/null 2>&1; then
    log_inline "stopping MongoDB "
    kill -9 `cat $MONGODB_PID_FILE`
    wait_for_stop_or_force $MONGODB_PID_FILE $MAX_WAIT_TIME
    rm -f $MONGODB_PID_FILE
  else
    log "could not stop MongoDB. check if process `cat $MONGODB_PID_FILE` exists"
    exit 0
  fi
else
  log "no MongoDB to stop"
fi

sleep 2

if [ -f $MONGODB_PID_FILE ]; then
  log "Failed to stop MongoDB process at `cat $MONGODB_PID_FILE`"
else
  log "MongoDB process is stopped"
fi



