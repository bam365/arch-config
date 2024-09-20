#!/bin/bash
vmstat 1 | while read line ;
do
    IDLE=$(echo $line | awk '{print $15}')
    CPUPCT=$(expr 100 - $IDLE 2>/dev/null)
    echo $CPUPCT
done
