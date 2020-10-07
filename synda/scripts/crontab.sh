#!/bin/evn bash

## This is a crontab scheduled task, running automatically every 30 mins

. /projects/NS9252K/share/synda/scripts/raw2dkrz.sh --project=cmip6 --action=move --input="/projects/NS9252K/rawdata/model" --keeplink=false --overwrite=false --autofix=false --verbose=false &>>/projects/NS9252K/rawdata/model/logs/$(date +%Y-%m-%d).log
