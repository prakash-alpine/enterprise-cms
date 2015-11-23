#!/usr/bin/env bash

. $RAILS_HOME/script/app_config.sh

if [ "$RAILS_HOME" = "" ]; then
    RAILS_HOME=$PWD
fi

cur_dir=$PWD

if [ "$MONGODB_HOST" = "" ]; then
    MONGODB_HOST=127.0.0.1
fi

if [ "$MONGODB_PORT" = "" ]; then
    MONGODB_PORT=27017
fi

MONGODB_PID_FILE=$RAILS_HOME/tmp/pids/mongodb.pid

log "Starting MongoDB"
cd $RAILS_HOME
# echo $PWD

# If MongoDB is already running, exit.

# NOTE: need a better way of checking if process is in running state
# if [ test -f $MONGODB_PID_FILE ]  && [ $(pgrep mongod) == `head -1 $MONGODB_PID_FILE` ]; then
if ( test -f $MONGODB_PID_FILE ); then
    log "MongoDB already running as process `cat $MONGODB_PID_FILE`."
    exit 1
fi

# NOTE: see redis.conf for options to store PID etc.

mongod --fork -bind_ip $MONGODB_HOST -port $MONGODB_PORT  --dbpath $RAILS_HOME/data/mongodb --logpath $RAILS_HOME/log/mongodb.log

pgrep mongod >  $RAILS_HOME/tmp/pids/mongodb.pid

wait_for_start $MONGODB_PID_FILE

echo "MongoDB process started as daemon"


