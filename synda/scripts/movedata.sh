#!/usr/bin/env bash
#set -e

date
[ ! -d logs ] && mkdir logs
while read -r fname
do
    # experiment id
    expid=$(echo ${fname} |awk -F/ '{print $NF}')
    echo $expid

    ./raw2dkrz.sh --project=cmip6 --action=move --input="$fname" --keeplink=true --force=true \
        1>./logs/${expid}.log 2>./logs/${expid}.err  &

    # numer of raw2dkrz.sh processes
    nps=$(ps x |command grep 'raw2dkrz.sh' |sed 's~\./~+~g' |cut -d"+" -f2 |sort -u |wc -l)
    # exclude the 'grep raw2dkrz.sh' command
    ((nps-=1))

    # set maximumn 5 running processes
    if [ $nps -lt 5 ]; then
        continue
    else
        wait && n=1
        date
    fi
done <list/explist200910.txt


