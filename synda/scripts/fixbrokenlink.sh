#!/bin/env bash
#set -x

cd /projects/NS9252K
#find CMIP6 -xtype l -print >brokenlink.txt

backup=/projects/NS9252K/.snapshots/Sunday-06-Sep-2020
N=10
cnt=1
while read -r file
do
    ((i=i%N)); ((i++==0)) && wait
    echo $cnt && ((cnt++))

    echo $file
    fpath=$(dirname $file)
    fname=$(basename $file)
    link=$(readlink -f $file)
    #echo $fname
    #echo $link
    # is link and not broken
    if [ -L $file ] && [ -e $file ]; then
        echo "link exists"
        continue
    fi
    # not a file, e.g., broken link
    if [ ! -e $file ]; then
        rm -f $file
        rm -f $link
        cp $backup/$file $file
        if [ $? -ne 0 ];then
            echo "download data with synda"
            synda get -q -f --verify_checksum --dest_folder /projects/NS9252K/$fpath $fname 1>/dev/null
        fi
    fi
    /projects/NS9252K/share/synda/scripts/raw2dkrz.sh --project=cmip6 --action=move --input="$file" --keeplink=true --autofix=true &
done </projects/NS9252K/share/synda/scripts/brokenlink.txt

# final check
echo "** FINAL CHECK **"
while read -r fname; do
    [ ! -e $fname ] && ls -l $fname
done</projects/NS9252K/share/synda/scripts/brokenlink.txt
