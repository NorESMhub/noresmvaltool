#/bin/env bash
if [ $# -ne 1 ] || [ $1 == "--help" ] || [ $1 == "-h" ]
then
    echo " "
    echo "find files/folders with permission/owership problem"
    echo " "
    echo "Usage:"
    echo "  findperm.sh /path/to/directory/to/be/fixed"
    echo "  e.g.,"
    echo "  findperm.sh /projects/NS9560K/ESGF/CMIP6"
    echo " "
    echo "** EXIT **"
    exit 1
fi

# create log file
logfile=/tmp/findperm-$(date +%Y-%m-%d).log
if [ ! -f $logfile ]
then
    touch $logfile
    chmod 664 $logfile
    chown $USER:ns9560k $logfile
fi

# add file group write permission
find $1 -type f ! -perm -g=w -ls |tee -a $logfile

# add folder group writeable permission
find $1 -type d -name '[[:alnum:]]*' ! -perm 2775 -ls | tee -a $logfile

# change group of files and folders to ns9560k
find $1 ! -group ns9560k -ls | tee -a $logfile

# find core dump files
find $1 -type f -name 'core.*' -ls |tee -a $logfile

# list all users who need to act
cat $logfile |sed 's/ * / /g' |cut -d" " -f5 |sort -u
