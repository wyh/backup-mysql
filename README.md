backup-mysql
============

a script of  utilizing percona innobackupex to automatically backup mysql data online


### requirements 

This script needs percona xtracbackup tool, which backups mysql online. For more information, please visit: [ percona xtrabackup ] (http://www.percona.com/software/percona-xtrabackup)  

Before executing this script, a mysql user should be created. Example code below:

```
CREATE USER 'bkpuser'@'localhost' IDENTIFIED BY 's3cret';
GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'bkpuser'@'localhost';
FLUSH PRIVILEGES;

```

The secret will be used in the script as the parameter of password. You need to change this in the script.

###  what does the script do?

1. Make a full backup to mysql data on each 01, 08, 15, 23 of each month
2. Make a daily incremental back to mysql data on the other days
3. Automatically  remove the first backup if the second backup finished
4. Compress and encrypt the backed up data to a remote server

### how to run?

1. Beforing running, make sure a back up directory available.
2. Make sure root user can access to the remote server directly, that's, without password. You can not feed a password in crontab. Use ssh-copy-id on ubuntu servers.
3. User on the remote server has the permission to write in the backup directory. Remote login as a root user is not recommended.
4. change secret in the script before running
4. run it. (1 forced to make full backup)
    ```
        sudo backup_mysql.sh /backup/dir remote@server /remote/backup/dir 1
    ```
### how to restore the data?

Please read percona xtrabackup manual.
