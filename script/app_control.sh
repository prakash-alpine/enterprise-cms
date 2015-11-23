#!/usr/bin/env bash

. $RAILS_HOME/script/app_config.sh

if [ "$RAILS_HOME"  == "" ]; then
    echo "You must set RAILS_HOME env variable before running this script."
    exit 1
fi

bin=$RAILS_HOME/script

echo $bin

command=$1
shift


services=(${@})

  # check to see if script is programmed to manage a service or a process
  function should_handle () {
    # If no services are provided, or $1 is a service to start
    [ ${#services[@]} -eq 0 ] || contains ${services[@]} $1
  }

  function contains() {
      local n=$#
      local value=${!n}
      for ((i=1;i < $#;i++)) {
          if [ "${!i}" == "${value}" ]; then
              return 0
          fi
      }
      return 1
  }


function start () {
  EXIT_STATUS=0
  pushd $RAILS_HOME > /dev/null

    if should_handle mongodb;  then
      $bin/start_mongodb.sh;
      EXIT_STATUS=`expr $EXIT_STATUS + $?`;
    fi

    if should_handle rails; then
       $bin/start_rails.sh;
       EXIT_STATUS=`expr $EXIT_STATUS + $?`;
    fi
}

function stop () {
  while getopts "t:" OPTION; do
       case $OPTION in
           t)
               MAX_WAIT_TIME=$OPTARG
               ;;
       esac
  done
  shift $(( OPTIND - 1 ))
  services=(${@})

  EXIT_STATUS=0
  pushd $CHORUS_HOME > /dev/null


    if should_handle rails; then
       $bin/stop_rails.sh;
       EXIT_STATUS=`expr $EXIT_STATUS + $?`;
    fi
    if should_handle mongodb; then
       $bin/stop_mongodb.sh;
       EXIT_STATUS=`expr $EXIT_STATUS + $?`;
    fi

  popd > /dev/null
  if (($EXIT_STATUS > 0)); then
    exit $EXIT_STATUS;
  fi
}

case $command in
    start )
        start
        ;;
    stop )
        stop ${@}
        ;;
    restart )
        stop ${@}
        start
        ;;
    monitor )
       monitor
       ;;
    backup )
       backup ${@}
       ;;
    restore )
       restore ${@}
       ;;
	setup )
	   setup ${@}
	   ;;
	health_check )
	   health_check ${@}
	   ;;
	configure )
	   configure ${@}
	   ;;
	migrate )
	   migrate ${@}
	   ;;
    * )
       usage
       ;;
esac

exit 0
