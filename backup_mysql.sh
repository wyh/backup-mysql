backup_dir=$1;
remote_server=$2
remote_backup_dir=$3
forced=$4
fullback_days="01 08 15 23"
password="PASSWORD"

cd $backup_dir;
mkdir -p full;
mkdir -p incr;
ssh $remote_server "mkdir -p $remote_backup_dir/full; mkdir -p $remote_backup_dir/incr"

fullbase_dir=`echo $backup_dir/full`;

day=`date +'%F'|grep -oe '-[0-9][0-9]$'|sed 's/-//'`;
if [ $forced -eq 1 ]; then 
    # forced a full backup
    day=`echo 01`
fi
match=`echo $fullback_days | grep -o $day`;

if [ ! -z $match ]; then
    # do a full back
    echo "date of today is $day, belongs to $fullback_days. Make an full backup"
    cd full
    # delete all current directory to save space
    rm -rf *
    innobackupex --user=bkpuser --password=$password $fullbase_dir
    if [ $? -eq 0 ]; then 
        echo "successfully completed backup"
        echo "zip and encrypt backup directory to remote server"
        fullbackup_dir=`ls -1 |tail -1`;
        tar -cvzf - $fullbackup_dir | openssl des3 -salt -k $password | ssh $remote_server "cat > $remote_backup_dir/full/$fullbackup_dir.tgz.des3"
        cd $backup_dir;
    fi

else
    # do an incremental backup
    echo "date of today is $day, not in $fullback_days. Make an incremental backup"
    fullbackup_dir=`ls -1 $backup_dir/full/|tail -1`;
    echo "fullbackup_dir: $fullbackup_dir"
    innobackupex --user=bkpuser --password=$password --incremental $backup_dir/incr/ --incremental-basedir=$fullbase_dir/$fullbackup_dir
    if [ $? -eq 0 ]; then
        echo "successfully made an incremental backup"
        echo "zip and encrypt this newly created incremental backup to remote server"
        cd incr;
        incr_dir=`ls -1 |tail -1`;
        tar -cvzf - $incr_dir | openssl des3 -salt -k $password | ssh $remote_server "cat > $remote_backup_dir/incr/$incr_dir.tgz.des3"
        echo "completed moving incremental backup to remote server: $remote_server"
        # deleted the backed up incr directory since it has been transfered to the remote server
        rm -rf $incr_dir
    fi;
    cd $backup;
fi
