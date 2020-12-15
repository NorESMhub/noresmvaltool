#!/bin/env bash

## This is a crontab scheduled task, running automatically every 30 mins (nird login node0)
#*     *     *   *    *        command to be executed
#-     -     -   -    -
#|     |     |   |    |
#|     |     |   |    +----- day of week (0 - 6) (Sunday=0)
#|     |     |   +------- month (1 - 12)
#|     |     +--------- day of month (1 - 31)
#|     +----------- hour (0 - 23)
#+------------- min (0 - 59)
#0,30   *     *   *    *        . /projects/NS9252K/share/synda/scripts/crontab.sh

njobs=$(ps x |grep -v 'grep' |grep -c 'raw2dkrz.sh')

# if running jobs
if [ $njobs -ge 1 ]; then
    exit
fi

. /projects/NS9252K/share/synda/scripts/raw2dkrz.sh --project=cmip6 --action=move --input="/projects/NS9252K/rawdata/autosort" --keeplink=false --overwrite=true --autofix=true --verbose=false &>>/projects/NS9252K/rawdata/logs/$(date +%Y-%m-%d).log
