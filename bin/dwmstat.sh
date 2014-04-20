#!/bin/bash
# dwmstat.sh - Run status bar for awesome wm

export STATCL1="\\00AB00"
export STATCL2="\\CCCCCC"
PIDFILE=$HOME/.dwmstat.pid
if [ -r $PIDFILE ];
then
    echo "dwm status program already running. If it really isn't, delete"
    echo $PIDFILE
else
    touch $PIDFILE
    trap "{ rm -f $PIDFILE; exit 0; }" SIGINT SIGTERM EXIT
    STATUSRET=0
    status | while read -r; do xsetroot -name "$REPLY"; done &
fi
