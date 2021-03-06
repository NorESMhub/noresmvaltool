#!/bin/env bash
#set -ex

# sort and move downloaded raw cmip5/cmip6 data
# to DKRZ folder structure under /projects/NS9252K/ESGF
# yanchun.he@nersc.no; last update: 2020.09.11

if [ $# -eq 0 ] || [ $1 == "-h" ] || [ $1 == "--help" ]
then
    printf "\n"
    printf "Usage:\n"
    printf 'raw2dkrz.sh
        --input=["files or/and folders patterns"]
                                    : (optional) default to /projects/NS9252K/rawdata/model;
                                      file or/and folder/path patterns (use " " for matching patters)
        --action=[move|link]        : (optional) default move; move the file or hard link the file
        --keeplink=[true|false]     : (optional); default false; only applies when --action==move
        --dryrun=[true|false]       : (optional); default false
        --overwrite=[true|false]    : (optional); default true; force the action/overwrite the file at destination
        --autofix=[true|false]      : (optional); default true; automatic download files with wrong checksum
        --verbose=[true|false]      : (optional); default true; automatic download files with wrong checksum'
    printf "\n"
    printf "Example:\n"
    printf '1: raw2dkrz.sh --input="/path/filepatterns*.nc /path/to/folders"\n'
    printf '2: raw2dkrz.sh --input="/path/filepatterns*.nc and/or /path/to/folders" --action=move --keeplink=true --overwrite=true --autofix=true\n'
    printf "\n"
    exit 1
else
    # set default value
    #project=cmip6 (update 22JAN2021: this is automatically detected)
    action=move
    dryrun=false
    keeplink=false
    overwrite=true
    autofix=true
    verbose=true
    input=/projects/NS9252K/rawdata/model
    while test $# -gt 0; do
        case "$1" in
            --project=*)
                #project=$(echo $1|sed -e 's/^[^=]*=//g')
                echo "--project option is not needed anymore, as it will be detected"
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
            --verbose=*)
                verbose=$(echo $1|sed -e 's/^[^=]*=//g')
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
if [ -z $ST_HOME ];then
    export ST_HOME=${HOME}/.synda
fi
# test if synda is initialised
if [ ! -d ~/.synda ]; then
    echo "Seems this is the first time for you to run Synda"
    echo "Initialize Synda configuration wizard"
    echo "Find out more information: https://github.com/orgs/NorESMhub/teams/esmvaltool-on-nird/discussions/5"
    echo ""
    synda check-env
fi
# check if configured correctly
# alternative file for test cfc12global_Amon_CESM2_historical_r11i1p1f1_gn_200001-201412.nc
#synda get -f -d /tmp  orog_fx_NorESM2-LM_historical_r1i1p1f1_gn.nc &>/dev/null
# (synda get may fail for not subscribing to role/group?)
synda dump orog_fx_NorESM2-LM_historical_r1i1p1f1_gn.nc &>/dev/null
if [ $? -ne 0 ];then
    echo "** WARNING **"
    echo "Synda may not configured correctly"
    echo "Find out more information: https://github.com/orgs/NorESMhub/teams/esmvaltool-on-nird/discussions/5"
    echo ""
fi

if $verbose; then
  echo "--- Job starts ---"
  date
  echo "------------------"
  echo ""
fi

[ ! -d /projects/NS9252K/rawdata/autosort/failed ] && \
    mkdir -p /projects/NS9252K/rawdata/autosort/failed

esgf=/projects/NS9252K/ESGF

pid=$$
## generate filelist of all matching files
for list in $(echo $input)
do

    if [ -L $list ]; then
        echo "** WARNING **"
        echo "   $list "
        echo -e "is a link! SKIP...\n"
    elif [ -f $list ]; then
        if [ ${list: -3} == ".nc" ]; then
            readlink -e $list >>/tmp/filelist.$pid  #use absolute path
        else
            echo "** WARNING **"
            echo "   $list "
            echo -e "   is not NetCDF file! SKIP...\n"
        fi
    elif [ -d $list ]; then
        find $list -not -path '*/failed/*' -type f -name '*.nc' -print >>/tmp/filelist.$pid
    else
        echo "** WARNING **"
        echo "   $list "
        echo -e "does not exist! SKIP...\n"
    fi
done

if [ ! -f /tmp/filelist.$pid ]; then
    echo "** WARNING **"
    echo " Noting to move, EXIT"
    exit
fi

## loop through all files
while read -r fname
do
    # local source file name and variable name
    ncpath=$(dirname $fname)
    ncfile=$(basename $fname)
    varname=$(echo $ncfile |cut -d"_" -f1)
    # checksum of remote file.
    #metainfo="$(synda show $ncfile)"
    #checksumr=$(echo "$metainfo" |grep 'checksum' |cut -d" " -f2 2>/dev/null)
    # file information retrieved by synda
    #fileremote=$(echo "$metainfo" |grep 'file:'|cut -d":" -f2 |sed 's/^\s//g')
    # convert the retreived information to dkrz folder structure
    #dkrz=$(echo $fileremote |awk -F. '{ for(i=1;i<=NF-2;i++) printf "%s/",$i; printf "\n"}'|sed 's/\/$//')
    # get file version information
    #version=$(echo $fileremote |awk -F. '{print $(NF-2)}')

    items=($(synda dump -f $ncfile replica=false -C checksum,dataset_version,local_path,project,checksum_type -F value 2>/tmp/synda.log.$pid))
    # if file not found at ESGF
    if [ ${#items[*]} -eq 0 ]; then
        echo "** ERROR **"
        echo "$ncfile"
        echo "NOT found at ESGF"
        echo "(likely all matching datasets have been retracted from ESGF)"
        echo "(or Synda is not corrected configured)"
        echo "More error message from Synda"
        echo "****************************"
        cat /tmp/synda.log.$pid
        echo "****************************"
        if ! $dryrun
        then
            echo "move $ncfile to /projects/NS9252K/rawdata/autosort/failed/ ..."
            mv $ncfile /projects/NS9252K/rawdata/autosort/failed/
        fi
        continue
    fi
    flag=false
    checksumrs=()
    for (( n =((${#items[*]}/5)); n>=1; n-- ))  # loop from latest version
    do

        checksumr=${items[($n-1)*5+1]}      # checksum of remote file
        checksum_type=${items[($n-1)*5+4]}  # checksum type
        # checksum of local file
        if [ $checksum_type == "sha256" ]; then
            checksuml=$(sha256sum $fname |cut -d" " -f1)
        elif [ $checksum_type == "md5" ]; then
            checksuml=$(md5sum $fname |cut -d" " -f1)
        else
            echo "** ERROR: unknown checksum_type **"
            echo "** EXIT                    ** "
            exit
        fi

        # if checksum of the local and remote files match
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
        else
            echo "move $ncfile to failed/ ..."
            mv $ncfile failed/
        fi
        # continue, the downloaded file will not moved,
        # but wait until the next time when this is script will be invoked again
        # and the above proceedure will be repeated
        continue
    fi

    # get local dkrz folder structure
    project=$(echo ${items[($n-1)*5]}| tr "[a-z]" "[A-Z]")
    version=${items[($n-1)*5+2]}
    local_path=${items[($n-1)*5+3]}
    dkrz=$(dirname $local_path)


    # destination dir
    if [ $project == "CMIP5" ]; then
        destdir=$esgf/$dkrz/$varname
    else
        destdir=$esgf/$dkrz
    fi

    # move file to dkrz folder structure
    umask 002
    ! $dryrun && [ ! -d $destdir ] && mkdir -p $destdir
    chmod g+s $destdir
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
            mv -v $fname $destdir/$ncfile
            [ $(stat -c '%a' $destdir/$ncfile) -ne 664 ] && chmod 644 $destdir/$ncfile
            [ $(stat -c '%G' $destdir/$ncfile) != 'ns9252k' ] && chown $USER:ns9252k $destdir/$ncfile
            # make a softlink back in the source folder
            if $keeplink && [ $? -eq 0 ]
            then
                srcdirlevs=$(dirname $fname |awk -F/ '{print NF}')
                # upper dirs excluding /projects/NS9252K
                upperdir=""
                for (( i = 0; i < $srcdirlevs-3; i++ )); do
                    upperdir="${upperdir}../"
                done
                if [ $project == "CMIP5" ]; then
                    ln -s ${upperdir}ESGF/$dkrz/$varname/$ncfile $fname 
                else
                    ln -s ${upperdir}ESGF/$dkrz/$ncfile $fname 
                fi
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
        if [ $project == "CMIP5" ]; then
            latestversion=$(ls $destdir/../../ |grep -E 'v20[0-9]{6}' |sort |tail -1)
            ln -sfT "$latestversion"  "$destdir/../../latest"
        else
            latestversion=$(ls $destdir/../ |grep -E 'v20[0-9]{6}' |sort |tail -1)
            ln -sfT "$latestversion"  "$destdir/../latest"
        fi
    fi
done < /tmp/filelist.$pid
rm -f /tmp/filelist.$pid
rm -f /tmp/synda.log.$pid

if $verbose; then
  echo "---- Job ends  ---"
  date
  echo "------------------"
fi

