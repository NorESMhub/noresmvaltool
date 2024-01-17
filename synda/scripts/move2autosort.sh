#!/bin/bash

ESGF_ROOT=/projects/NS9560K-datalake/ESGF
[ ! -d $ESGF_ROOT ] && ESGF_ROOT=/nird/datalake/NS9560K/ESGF
[ ! -d $ESGF_ROOT ] && echo "$ESGF_ROOT does not exist, EXIT" && exit 1

echo " "
echo "Description:"
echo "This script will move download CMIP6 model data to"
printf "\t\e[4m $ESGF_ROOT/rawdata/autosort/ \e[0m\n"
echo "with permission check and fixes."

if [ $# -eq 0 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
    printf "\n"
    printf "\e[1mUsage:\n"
    printf '\t move2autosort.sh "/path/to/files_or_folders" \e[0m\n'
    printf '\t\e[4m (NOTE the quote if you pass a file name pattern as input!!)\e[0m\n'
    printf 'Example 1: move files\n'
    printf '\tmove2autosort.sh "/path/to/files*.nc"\n'
    printf 'Example 2: move folders\n'
    printf '\tmove2autosort.sh "/path/to/folders*.nc"\n'
    printf 'Example 3: move files and folders\n'
    printf '\tmove2autosort.sh "/path/to/files*.nc /path/to/folders*.nc"\n'
    exit 1
fi

for list in $(echo $1)
do

    if [ -L $list ]; then
        echo "** WARNING **"
        echo "   $list "
        echo -e "is a link! SKIP...\n"
    elif [ -f $list ]; then
        if [ ${list: -3} == ".nc" ]; then
            if [ $(stat -c %a $list) -ne 664 ]; then
                chmod 664 $list
                [ $? -ne 0 ] && echo "ERROR chmod to 664 of $list" && continue
            fi
            if [ $(stat -c %g $list) -ne 219560 ]; then
                chgrp 219560 $list
                [ $? -ne 0 ] && echo "ERROR chgrp to 219560 of $list" && continue
            fi
            mv $list $ESGF_ROOT/rawdata/autosort/
        else
            echo "** WARNING **"
            echo "   $list "
            echo -e " is not NetCDF file! SKIP...\n"
        fi
    elif [ -d $list ]; then
        find $list -type f -name '*.nc' ! -perm 664 -exec chmod 664 {} \;
        [ $? -ne 0 ] && echo "ERROR chmod to 664 of $list" && continue
        find $list -type d ! -perm 2775 -exec chmod 2775 {} \;
        [ $? -ne 0 ] && echo "ERROR chmod to 2775 of $list" && continue
        find $list ! -group 219560 -exec chgrp 219560 {} \;
        [ $? -ne 0 ] && echo "ERROR chgrp to 219560 of $list" && continue
        mv $list $ESGF_ROOT/rawdata/autosort/
    else
        echo "** WARNING **"
        echo " $list "
        echo "does not exist!"
        echo -e "** SKIP **\n"
    fi
done
