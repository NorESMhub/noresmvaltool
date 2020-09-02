#!/bin/env bash
set -e

# sort and move cmip5/cmip6 data of ETHZ folder structure to DKRZ folder structure
# yanchun.he@nersc.no; last update: 2020.09.02

if [ $# -lt 3 ] || [ $1 == "--help" ]
then
    printf "\n"
    printf "Usage:\n"
    printf 'sort_cmip.sh \
        --project=[cmip5|cmip6]     : set phase of CMIP data \
        --action=[move|link]        : move the file or hard link the file \
        --input=[patterns for files or/and folders]  : file  or/and folder/path patterns (use " " for matching patters\
        --keeplink=[true|false]     : optional, only applies when --action==move \
        --dryrun=[true|false]       : optional \
        --force=[true|false]        : force the action \
        \n'
    printf "\n"
    printf "Example:\n"
    printf 'sort_cmip.sh --project=cmip6 --action=move --input="/filepath/filepattern*.txt /another/folder/path" --keeplink=true --force=true\n'
    printf "\n"
    exit 1
else
    # set default value
    dryrun=false
    keeplink=false
    force=true
    while test $# -gt 0; do
        case "$1" in
            --project=*)
                project=$(echo $1|sed -e 's/^[^=]*=//g')
                shift
                ;;
            --action=*)
                action=$(echo $1|sed -e 's/^[^=]*=//g')
                shift
                ;;
            --input=*)
                input=$(echo $1|sed -e 's/^[^=]*=//g')
                shift
                ;;
            --keeplink=*)
                keeplink=$(echo $1|sed -e 's/^[^=]*=//g')
                shift
                ;;
            --dryrun=*)
                dryrun=$(echo $1|sed -e 's/^[^=]*=//g')
                shift
                ;;
            --force=*)
                force=$(echo $1|sed -e 's/^[^=]*=//g')
                shift
                ;;
            * )
                echo "ERROR: option $1 not allowed."
                echo "*** EXITING THE SCRIPT"
                exit 1
                ;;
        esac
    done
fi

alias synda=/projects/NS9252K/conda/synda/bin/synda

echo "--- Job starts ---"
date
echo "------------------"

esgf=/projects/NS9252K/ESGF

pid=$$
for list in $(echo $input)
do

    if [ -f $list ]; then
        if [ ${list: -3} == ".nc" ]; then
            echo $list >>/tmp/filelist.$pid
        else
            echo "** WARNING **"
            echo "   $list "
            echo "   is not NetCDF file! SKIP..."
        fi
    elif [ -d $list ]; then
        find $list -type f -name '*.nc' -print >>/tmp/filelist.$pid
    else
        echo "** WARNING **"
        echo "   $list "
        echo "   does not exist, SKIP..."
    fi
done

while read -r fname
do
    # local source file name and variable name
    ncfile=$(echo $fname |awk -F/ '{print $NF}')
    varname=$(echo $ncfile |cut -d"_" -f1)
    # sha256sum of local file
    checksuml=$(sha256sum $fname |cut -d" " -f1)
    # sha256sum of remote file. Note synda show the oldest version (latest=true does not help)
    # (synda can retrieve the correct version, at least for cmip6)
    # (e.g., synda show tas_Amon_CESM2_abrupt-4xCO2_r1i1p1f1_gn_045001-049912.nc shows the correct version v20190927)
    # (and synda version CMIP6.CMIP.NCAR.CESM2.abrupt-4xCO2.r1i1p1f1.Amon.tas.gn.v20190927, shows there are four versions)
    checksumr=$(synda show $ncfile |grep 'checksum' |cut -d" " -f2)
    # file information retrieved by synda
    fileremote=$(synda show $ncfile |grep 'file:')
    # convert the retreived information to dkrz folder structure
    dkrz=$(echo $fileremote |cut -d":" -f2 |tr -d " " |awk -F. '{ for(i=1;i<=NF-2;i++) printf "%s/",$i; printf "\n"}'|sed 's/\/$//')
    # get file version information
    version=$(echo $fileremote |awk -F. '{print $(NF-2)}')
    # if any error with retrieving the data at ESGF
    if [ $? -ne 0 ]; then
        echo "$ncfile not found at ESGF"
    fi

    # destination dir
    if [ $project == "cmip5" ]; then
        destdir=$esgf/$dkrz/$varname
    else
        destdir=$esgf/$dkrz
    fi

    # check if sha256sum of the local and remote files match
    if [ "$checksuml" != "$checksumr" ]; then
        echo "checksum at local file:"
        echo "$fname"
        echo "differs with remote file:"
        echo $dkrz/$ncfile
        echo " "
        echo "Ingore, and move to the next... "
        continue
    fi
    # move file to dkrz folder structure
    ! $dryrun && [ ! -d $destdi ] && mkdir -p $destdir
    if [ -f $destdir/$ncfile ]; then
        if $force; then
            rm -f $destdir/$ncfile
        else
            echo "** WARNING **"
            echo $destdir/$ncfile
            echo "already exits! Ingore and move to the next... "
            continue
        fi
    fi
    if [ $action == "move" ]; then
        if $dryrun
        then
            echo "** DRY RUN **"
            echo "mv -v $fname $destdir/$ncfile"
        else
            [ ! -d $destdir ] && mkdir -p $destdir
            mv -v $fname $destdir/$ncfile
            if $keeplink
            then
                ln -s $destdir/$ncfile $fname 
            fi
        fi
    else
        if $dryrun
        then
            echo "** DRY RUN **"
        else
            [ ! -d $destdir ] && mkdir -p $destdir
            ln $fname $destdir/$ncfile
        fi
        echo "ln $fname $destdir/$ncfile"
    fi
    if ! $dryrun
    then
        latestversion=$(ls $destdir/../ |grep -E 'v20[0-9]{6}' |sort |tail -1)
        ln -sfT "$latestversion"  "$destdir/../latest"
    fi
done < /tmp/filelist.$pid
rm -f /tmp/filelist.$pid

echo "---- Job ends  ---"
date
echo "------------------"
