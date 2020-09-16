#!/usr/bin/env bash
#set -e

list=$1
if [ ! -f $list ]
then
    echo "folder list: $list is not found..."
    exit 1
fi

date
nps=1
[ ! -d logs ] && mkdir logs
while read -r fname
do
    # experiment id
    expid=$(echo ${fname} |awk -F/ '{print $NF}')
    echo $expid

    ./raw2dkrz.sh --project=cmip6 --action=move --input="$fname" --keeplink=true --overwrite=true --autofix=true\
        1>./logs/${expid}.log 2>./logs/${expid}.err  &

    # keep maximumn 10 jobs
    flag=true
    while $flag ; do
        # numer of raw2dkrz.sh processes
        nps=$(ps x |command grep 'raw2dkrz.sh' |sed 's~\./~+~g' |cut -d"+" -f2 |sort -u |wc -l)
        # exclude the 'grep raw2dkrz.sh' command
        ((nps-=1))

        if [ $nps -lt 10 ]; then
            flag=false
            sleep 5s
            date
        else
            sleep 600s
        fi
    done

done <$list


