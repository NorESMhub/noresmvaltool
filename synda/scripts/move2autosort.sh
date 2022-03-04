#!/bin/bash
# move2autosort.sh  :move download CMIP6 model data to autosort/ folder

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
            [ $(stat -c %a $list) -ne 664 ] && chmod 664 $list
            [ $(stat -c %g $list) -ne 219252 ] && chgrp 219252 $list
            mv $list /cluster/shared/ESGF/rawdata/autosort/
        else
            echo "** WARNING **"
            echo "   $list "
            echo -e " is not NetCDF file! SKIP...\n"
        fi
    elif [ -d $list ]; then
        find $list -type f -name '*.nc' ! -perm 664 -exec chmod 664 {} \;
        find $list -type d ! -perm 2775 -exec chmod 2775 {} \;
        find $list ! -group 219252 -exec chgrp 219252 {} \;
        [ $? -eq 0 ] && mv $list /cluster/shared/ESGF/rawdata/autosort/
    else
        echo "** WARNING **"
        echo " $list "
        echo "does not exist!"
        echo -e "** SKIP **\n"
    fi
done
