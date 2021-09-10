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
#0,30   *     *   *    *        . /projects/NS9252K/share/synda/scripts/crontab.sh

njobs1=$(ps x |grep -v 'grep' |grep -c 'raw2dkrz.sh')
njobs2=$(ps x |grep -v 'grep' |grep -c 'crontab.sh')

# if running jobs
if [ $njobs1 -ge 1 ] || [ $njobs2 -ge 3 ]; then
    exit
fi

logpath=/projects/NS9252K/rawdata/logs
logfile=$(date +%Y-%m-%d).log
touch $logpath/$logfile
[ stat -c "%a" $logfile -ne 664 ] && chmod 664 $logfile

/projects/NS9252K/share/synda/scripts/raw2dkrz.sh \
    --action=move \
    --input="/projects/NS9252K/rawdata/autosort" \
    --keeplink=false \
    --overwrite=true \
    --autofix=false \
    --verbose=false \
    &>>$logpath/$logfile

# remove log files older than 30 days
find $logpath -ctime +30 -ls -exec rm -f {} \;
