#!/bin/env bash
#set -e

# sort and move downloaded raw cmip5/cmip6 data
# to DKRZ folder structure under /projects/NS9252K/ESGF
# yanchun.he@nersc.no; last update: 2020.09.11

if [ $# -lt 3 ] || [ $1 == "--help" ]
then
    printf "\n"
    printf "Usage:\n"
    printf 'raw2dkrz.sh \
        --project=[cmip5|cmip6]     : set phase of CMIP data \
        --action=[move|link]        : move the file or hard link the file \
        --input=[patterns for files or/and folders]  : file  or/and folder/path patterns (use " " for matching patters\
        --keeplink=[true|false]     : optional, only applies when --action==move; default false \
        --dryrun=[true|false]       : optional; default false \
        --overwrite=[true|false]    : force the action/overwrite the file at destination; default true \
        --autofix=[true|false]      : automatic download files with wrong checksum; default true \
        \n'
    printf "\n"
    printf "Example:\n"
    printf 'raw2dkrz.sh --project=cmip6 --action=move --input="/filepath/filepattern*.txt /another/folder/path" --keeplink=true --overwrite=true --autofix=true\n'
    printf "\n"
    exit 1
else
    # set default value
    dryrun=false
    keeplink=false
    overwrite=true
    autofix=true
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
            --overwrite=*)
                overwrite=$(echo $1|sed -e 's/^[^=]*=//g')
                shift
                ;;
            --autofix=*)
                autofix=$(echo $1|sed -e 's/^[^=]*=//g')
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
echo ""

esgf=/projects/NS9252K/ESGF

pid=$$
## generate filelist of all matching files
for list in $(echo $input)
do

    if [ -f $list ]; then
        if [ ${list: -3} == ".nc" ]; then
            readlink -e $list >>/tmp/filelist.$pid  #use absolute path
        else
            echo "** WARNING **"
            echo "   $list "
            echo -e "   is not NetCDF file! SKIP...\n"
        fi
    elif [ -d $list ]; then
        find $list -type f -name '*.nc' -print >>/tmp/filelist.$pid
    else
        echo "** WARNING **"
        echo "   $list "
        echo -e "   does not exist, SKIP...\n"
    fi
done

## loop through all files
while read -r fname
do
    # local source file name and variable name
    ncpath=$(dirname $fname)
    ncfile=$(basename $fname)
    varname=$(echo $ncfile |cut -d"_" -f1)
    # sha256sum of local file
    checksuml=$(sha256sum $fname |cut -d" " -f1)
    # sha256sum of remote file.
    #metainfo="$(synda show $ncfile)"
    #checksumr=$(echo "$metainfo" |grep 'checksum' |cut -d" " -f2 2>/dev/null)
    # file information retrieved by synda
    #fileremote=$(echo "$metainfo" |grep 'file:'|cut -d":" -f2 |sed 's/^\s//g')
    # convert the retreived information to dkrz folder structure
    #dkrz=$(echo $fileremote |awk -F. '{ for(i=1;i<=NF-2;i++) printf "%s/",$i; printf "\n"}'|sed 's/\/$//')
    # get file version information
    #version=$(echo $fileremote |awk -F. '{print $(NF-2)}')

    items=($(synda dump -f $ncfile -C checksum,dataset_version,local_path -F value 2>/dev/null))
    # if file not found at ESGF
    if [ ${#items[*]} -eq 0 ]; then
        echo "** ERROR **"
        echo "$ncfile"
        echo "NOT found at ESGF"
        echo -e "(likely all matching datasets have been retracted from ESGF)\n"
        continue
    fi
    flag=false
    checksumrs=()
    for (( n =((${#items[*]}/3)); n>=1; n-- ))  # loop from latest version
    do
        checksumr=${items[($n-1)*3]}    # checksum of remote file
        # check if sha256sum of the local and remote files match
        if [ "$checksuml" == "$checksumr" ]; then
            flag=true
            break
        fi
        checksumrs+=($checksumr)
    done
    if ! $flag
    then
        echo "** ERROR **"
        echo " Checksum of local file:"
        echo " $ncfile "
        echo " matches none of the remote ESGF files"
        echo " (likely the local file was retracted from ESGF, but other versions exist)"
        echo "checksum local:"
        echo "$checksuml"
        echo "checksum remote:"
        echo "${checksumrs[*]}" |sed 's/ /\n/g'
        echo ""

        if $autofix
        then
            echo "** The latest version will be downloaded! **"
            synda get -q -f --verify_checksum --dest_folder $ncpath $ncfile 1>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "File is downloaded sucessfully!\n"
                echo "       "
            else
                echo -e "File is not downloaded sucessfully\n"
                echo "       "
            fi
        fi
        # continue, the downloaded file will not moved,
        # but wait until the next time when this is script will be invoked again
        # and the above proceedure will be repeated
        continue
    fi

    # get local dkrz folder structure
    version=${items[($n-1)*3+1]}
    local_path=${items[($n-1)*3+2]}
    dkrz=$(dirname $local_path)

    # destination dir
    if [ $project == "cmip5" ]; then
        destdir=$esgf/$dkrz/$varname
    else
        destdir=$esgf/$dkrz
    fi

    # move file to dkrz folder structure
    ! $dryrun && [ ! -d $destdi ] && mkdir -p $destdir
    if [ -f $destdir/$ncfile ]; then
        if $overwrite; then
            rm -f $destdir/$ncfile
        else
            echo "** WARNING **"
            echo $destdir/$ncfile
            echo -e "already exits! Ingore and move to the next...\n"
            continue
        fi
    fi
    if [ $action == "move" ]; then
        if $dryrun
        then
            echo "** DRY RUN **"
            echo -e "mv -v $fname $destdir/$ncfile.\n"
        else
            [ ! -d $destdir ] && mkdir -p $destdir
            mv -v $fname $destdir/$ncfile
            # make a softlink back in the source folder
            if $keeplink && [ $? -eq 0 ]
            then
                srcdirlevs=$(dirname $fname |awk -F/ '{print NF}')
                # upper dirs excluding /projects/NS9252K
                upperdir=""
                for (( i = 0; i < $srcdirlevs-3; i++ )); do
                    upperdir="${upperdir}../"
                done
                ln -s ${upperdir}ESGF/$dkrz/$ncfile $fname 
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
        echo -e "ln $fname $destdir/$ncfile\n"
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
