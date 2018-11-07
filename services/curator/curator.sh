#!/bin/bash
set -e

. utils.sh

# start curator
curator --config /conf/curator.yml /conf/action.yml

# Do the backup
mkdir -p /mount/backups/my_backup/last_backup/
chown -R "$BACKUP_UID:$BACKUP_UID" /mount/backups/my_backup/
find /mount/backups/my_backup -maxdepth 1 -regex '/mount/backups/my_backup/last_backup/last-backup-.*' -delete
touch "/mount/backups/my_backup/last_backup/last-backup-$(date -u +"%Y-%m-%d-%H-%M-%Z")"
