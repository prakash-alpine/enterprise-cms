##### Required environment variables RAILS_HOME and RAILS_ENV #####

if [ "$RAILS_HOME" = "" ]; then
    echo RAILS_HOME not set, it should be set to the Rails installation directory
    exit 1
fi
# remove trailing '/' from RAILS_HOME
RAILS_HOME=`echo $RAILS_HOME | sed 's/\/$//'`

if [ "$RAILS_ENV" = "" ]; then
    if [ -f $RAILS_HOME/.development ]; then
        RAILS_ENV=development
    else
        RAILS_ENV=production
    fi
fi

# Test for interactive shell
if [ -t 0 ]; then
    SHELL_CONFIG=`stty -g`
fi

##### PID file locations #####

mkdir -p $RAILS_HOME/tmp/pids
CLOCKWORK_PID_FILE=$RAILS_HOME/tmp/pids/clockwork.pid
RAILS_PID_FILE=$RAILS_HOME/tmp/pids/puma.pid
SIDEKIQ_PID_FILE=$RAILS_HOME/tmp/pids/sidekiq.pid
REDIS_PID_FILE=$RAILS_HOME/tmp/pids/redis-server.pid
MONGODB_PID_FILE=$RAILS_HOME/tmp/pids/mongodb.pid
RAILS_PID_FILE=$RAILS_HOME/tmp/pids/puma.pid


## Function to test dependencies of processes. Checks the PID files in $RAILS_HOME/tmp dir
function depends_on () {
    missing_dependencies=()
    dependency_num=1
    until [ -z "$1" ]  # Until all parameters used up . . .
    do
        pid_file=`echo $1 | tr '[:lower:]' '[:upper:]'`_PID_FILE
        if [ ! -f ${!pid_file} ]; then
            missing_dependencies[$dependency_num]=$1
            dependency_num=$(($dependency_num + 1))
        fi
        shift
    done

    if [ ${#missing_dependencies[@]} -ne 0 ]; then
        joiner=""
        message=""
        for missing_dependency in ${missing_dependencies[*]}
        do
            message=$message$joiner$missing_dependency
            joiner=", "
        done
        log "$message must be running to start the $STARTING"
        exit 1
    fi
}

##### support functions #####

function log () {
    echo "[$RAILS_ENV] $1"
}

function log_inline () {
    echo -n "[$RAILS_ENV] $1"
}

function wait_for_start () {
    pid_file=$1
    process_name=$2
     # NOTE: need a better way of checking if process is in running state
     #until ( test -f $pid_file ) && ( pgrep $process_name == `head -1 $pid_file` > /dev/null 2>&1 )
     until ( test -f $pid_file )
    do
        sleep 1
    done
}

function wait_for_stop () {
    pid_file=$1
    # NOTE: need a better wasy of checking if process is stoppe. kill -0 is not supported on MacOSX. See 'man kill' manpage -> BUGS
    while kill -0 `head -1 $pid_file 2>/dev/null` > /dev/null 2>&1
    do
        echo -n "."
        sleep 1
    done
    echo " ( Stopped )"
}

DEFAULT_WAIT_TIME=5
function wait_for_stop_or_force () {
    pid_file=$1

    MAX_WAIT_TIME=${2:-$DEFAULT_WAIT_TIME} # this awful notation means use parameter $2 if not null, else use value $DEFAULT_WAIT_TIME.
    time_waited=0
    while kill -0 `head -1 $pid_file 2>/dev/null` > /dev/null 2>&1
    do
        echo -n "."
        sleep 1

        # Negative values -> indefinite wait
        if [ "$MAX_WAIT_TIME" -lt "0" ]; then
            continue
        fi

        # Else only wait at most MAX_WAIT_TIME
        let "time_waited++"
        if [ "$time_waited" -gt "$MAX_WAIT_TIME" ]; then
            echo " ( Forcing stop since > $MAX_WAIT_TIME sec. elapsed )"
            kill -9 `head -1 $pid_file 2>/dev/null` > /dev/null 2>&1
            break
        fi
    done
    echo " ( Stopped )"
}

function exit_control () {
    # Test for interactive shell
    test -t 0 && stty $SHELL_CONFIG
    exit $1
}


