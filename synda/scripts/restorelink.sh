#!/bin/env bash
#set -ex

ESGF_ROOT=/nird/datalake/NS9560K/ESGF
##find $ESGF_ROOT/CMIP6/CMIP -maxdepth 4 -print >rpath.txt
#ls -d $ESGF_ROOT/CMIP6/*/*/*/*/* >rpath.txt

while read -r rpath
do
    echo ${rpath} >>rpath_done.txt
    for fullfile in $(find $rpath -type f -print)
        do
        data=$(echo $fullfile |cut -d"/" -f4-)
        expid=$(echo $fullfile |cut -d"/" -f9)
        model=$(echo $fullfile |cut -d"/" -f8)
        real=$(echo $fullfile |cut -d"/" -f10)

        ln -s ../../../../$data $ESGF_ROOT/CMIP6/${expid}/${model}/${real}/.
    done
done <rpath.txt

