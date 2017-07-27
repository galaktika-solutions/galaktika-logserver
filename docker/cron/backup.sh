#!/bin/bash
set -e
DATE=$(date +%Y-%m-%d-%H-%M)
rsync -rvu --ignore-existing --recursive --delete /mount/backups/my_backup $BACKUP_DEST
echo $DATE > /home/myvertis/last_file_backup
rsync -rvu /home/myvertis/last_file_backup $BACKUP_DEST