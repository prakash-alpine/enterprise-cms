#!/bin/sh

PID_FILE=$RAILS_HOME/tmp/pids/server.pid

if [ -f $PID_FILE ]; then
    echo "Removing server.pid file"
    rm $PID_FILE
else
    echo "server.pid not found"
fi


