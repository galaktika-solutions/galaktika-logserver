#!/bin/bash
set -e
DATE=$(date +%Y-%m-%d-%H-%M)
rsync -rit --delete /mount/backups/my_backup $BACKUP_DEST
echo $DATE > /home/linux_backup/last_file_backup
rsync -rit /home/linux_backup/last_file_backup $BACKUP_DEST
