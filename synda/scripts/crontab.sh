#!/bin/env bash

## This is a crontab scheduled task, running automatically every 30 mins
## currently installed in login2
#*     *     *   *    *        command to be executed
#-     -     -   -    -
#|     |     |   |    |
#|     |     |   |    +----- day of week (0 - 6) (Sunday=0)
#|     |     |   +------- month (1 - 12)
#|     |     +--------- day of month (1 - 31)
#|     +----------- hour (0 - 23)
#+------------- min (0 - 59)
#MAILTO="yanchun.he@nersc.no"
#0,30   *     *   *    *        . /nird/datalake/NS9560K/ESGF/software/noresmvaltool/synda/scripts/crontab.sh  >/dev/null 2>&1

njobs1=$(ps x |grep -v 'grep' |grep -c 'raw2dkrz.sh')
njobs2=$(ps x |grep -v 'grep' |grep -c 'crontab.sh')

# if running jobs
if [ $njobs1 -ge 1 ] || [ $njobs2 -ge 3 ]; then
    exit
fi

ESGF_ROOT=/nird/datalake/NS9560K/ESGF
logpath=$ESGF_ROOT/rawdata/logs
logfile=$(date +%Y-%m-%d).log
touch $logpath/$logfile
[ $(stat -c "%a" $logpath/$logfile) -ne 664 ] && chmod 664 $logpath/$logfile
umask 0022

$ESGF_ROOT/software/noresmvaltool/synda/scripts/raw2dkrz.sh \
    --action=move \
    --input="$ESGF_ROOT/rawdata/autosort" \
    --keeplink=false \
    --overwrite=true \
    --autofix=true \
    --verbose=false \
    &>>$logpath/$logfile

# remove log files older than 30 days or empty files older than two days
find $logpath \( -mtime +30 -or -mtime +1 -empty \) -ls -exec rm -f {} \;
