#!/bin/env bash
#set -x

ESGF_ROOT=/projects/NS9560K-datalake/ESGF
[ ! -d $ESGF_ROOT ] && ESGF_ROOT=/nird/datalake/NS9560K/ESGF
[ ! -d $ESGF_ROOT ] && echo "$ESGF_ROOT does not exist, EXIT" && exit 1
cd $ESGF_ROOT/../
#find CMIP6 -xtype l -print >brokenlink.txt

backup=/projects/NS9560K/.snapshots/Sunday-06-Sep-2020
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
            synda get -q -f --verify_checksum --dest_folder /projects/NS9560K/$fpath $fname 1>/dev/null
        fi
    fi
    $ESGF_ROOT/software/noresmvaltool/synda/scripts/raw2dkrz.sh --project=cmip6 --action=move --input="$file" --keeplink=true --autofix=true &
done <$ESGF_ROOT/software/noresmvaltool/synda/scripts/brokenlink.txt

# final check
echo "** FINAL CHECK **"
while read -r fname; do
    [ ! -e $fname ] && ls -l $fname
done<$ESGF_ROOT/software/noresmvaltool/synda/scripts/brokenlink.txt
