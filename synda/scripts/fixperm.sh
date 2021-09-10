#/bin/env bash
if [ $# -ne 1 ] || [ $1 == "--help" ] || [ $1 == "-h" ]
then
    echo " "
    echo "Add file/folder group write permission, and fix group name to ns9252k. "
    echo " "
    echo "Usage:"
    echo "  fixperm.sh /path/to/directory/to/be/fixed"
    echo "  e.g.,"
    echo "  fixperm.sh /projects/NS9252K/ESGF/CMIP6"
    echo " "
    echo "** EXIT **"
    exit 1
fi

# create log file
logfile=/tmp/fixperm-$(date +%Y-%m-%d).log
if [ ! -f $logfile ]
then
    touch $logfile
    chmod 664 $logfile
    chown $USER:ns9252k $logfile
fi

# add file group write permission
find $1 -type f -user $USER ! -perm -g=w ! -name 'README' -ls -exec chmod g+w {} \; |tee -a $logfile

# add folder group writeable permission
find $1 -type d -user $USER -name '[[:alnum:]]*' ! -perm 2775 -ls -exec chmod g+w {} \; | tee -a $logfile

# change group of files and folders to ns9252k
find $1 -user $USER ! -group ns9252k -ls -exec chown $USER:ns9252k {} \; | tee -a $logfile

# find core dump files
find $1 -type f -user $USER -name 'core.*' -ls -delete |tee -a $logfile

