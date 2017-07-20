#!/bin/bash
set -e
DATE=$(date +%Y-%m-%d-%H-%M)
rsync -rvu /usr/share/elasticsearch/data $BACKUP_DEST
echo $DATE > /home/myvertis/last_file_backup
rsync -rvu /home/myvertis/last_file_backup $BACKUP_DEST
