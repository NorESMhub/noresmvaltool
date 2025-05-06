#!/bin/env bash
#set -e

# loop all the subfolders to link the latest version to latest
# yanchun.he@nersc.no
#July 08, 2020

if [ $# -ne 1 ]
then
    echo "Usage ./linklatest.sh /path/to/parent/folder"
    echo "Note, the specified path goes no deeper than the grid type"
    echo 'e.g., ./linklatest.sh ${ROOPATH}/CMIP6/CMIP/NCAR/CESM2/historical/r1i1p1f1/Amon/'
    exit
fi

#cd /projects/NS9034K/CMIP6
#for subdir1 in AerChemMIP C4MIP CDRMIP CMIP DAMIP LUMIP OMIP PAMIP PMIP RFMIP ScenarioMIP

for subdir1 in $(ls -d $1/*)
    do
    echo "---"
    echo subdir1: ${subdir1}
    echo "---"
    #for subdir2 in $(find $dir -type d \( -name 'g[a-z]' -o -name 'g[a-z][a-z0-9]' -o -name 'g[a-z][0-9][a-z]' \) -print)
    for subdir2 in $(find $subdir1 -type d \( -name 'gm' -o -name 'gn' -o -name 'gna' -o -name 'gng' -o -name 'gnz' -o -name 'gr' -o -name 'gr1' -o -name 'gr1a' -o -name 'gr1g' -o -name 'gr1z' -o -name 'gr2' -o -name 'gr2a' -o -name 'gr2g' -o -name 'gr2z' -o -name 'gr3' -o -name 'gr3a' -o -name 'gr3g' -o -name 'gr3z' -o -name 'gr4' -o -name 'gr4a' -o -name 'gr4g' -o -name 'gr4z' -o -name 'gr5' -o -name 'gr5a' -o -name 'gr5g' -o -name 'gr5z' -o -name 'gr6' -o -name 'gr6a' -o -name 'gr6g' -o -name 'gr6z' -o -name 'gr7' -o -name 'gr7a' -o -name 'gr7g' -o -name 'gr7z' -o -name 'gr8' -o -name 'gr8a' -o -name 'gr8g' -o -name 'gr8z' -o -name 'gr9' -o -name 'gr9a' -o -name 'gr9g' -o -name 'gr9z' -o -name 'gra' -o -name 'grg' -o -name 'grz' \) -print)
    do
        echo subdir2: $subdir2
        latestversion=$(ls $subdir2 |grep -E 'v20[0-9]{6}' |sort |tail -1)
        echo $latestversion
        if [ ! -L $subdir2/latest ] || [ $(readlink $subdir2/latest) != "$latestversion" ];then
            ln -sfT "$latestversion" "$subdir2/latest" 
            echo $subdir2:$latestversion
        fi
    done
done
