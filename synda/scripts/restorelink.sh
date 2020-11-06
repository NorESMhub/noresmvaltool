#!/bin/env bash
#set -ex

##find /projects/NS9252K/ESGF/CMIP6/CMIP -maxdepth 4 -print >rpath.txt
#ls -d /projects/NS9252K/ESGF/CMIP6/*/*/*/*/* >rpath.txt

while read -r rpath
do
    echo ${rpath} >>rpath_done.txt
    for fullfile in $(find $rpath -type f -print)
        do
        data=$(echo $fullfile |cut -d"/" -f4-)
        expid=$(echo $fullfile |cut -d"/" -f9)
        model=$(echo $fullfile |cut -d"/" -f8)
        real=$(echo $fullfile |cut -d"/" -f10)

        ln -s ../../../../$data /projects/NS9252K/CMIP6/${expid}/${model}/${real}/.
    done
done <rpath.txt

