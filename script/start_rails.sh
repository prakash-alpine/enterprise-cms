#!/usr/bin/env bash

. $RAILS_HOME/script/app_config.sh

if [ "$RAILS_ENV"  == "" ]; then
    RAILS_ENV='development'
fi

if [ "$RAILS_PORT"  == "" ]; then
    RAILS_PORT=3000
fi

log "Starting Rails"
# If puma is already running, exit.
if ( test -f $RAILS_PID_FILE ) && ( kill -0 `cat $RAILS_PID_FILE` > /dev/null 2>&1 ); then
    log "Rails already running as process `cat $RAILS_PID_FILE`."
    exit 1
fi

echo "Starting Rails server on port $RAILS_PORT"

puma  -p $RAILS_PORT -d -e $RAILS_ENV --pidfile=$RAILS_PID_FILE >> /dev/null

wait_for_start $RAILS_PID_FILE

if [ -f $RAILS_HOME/tmp/pids/puma.pid ]
then
 echo "Rails started in $RAILS_ENV mode on port $RAILS_PORT"
else
 echo "Failed to start Rails in $RAILS_ENV mode. Please see the logs in $RAILS_HOME/log/$RAILS_ENV.log file."
fi

