#!/bin/bash
set -e

mkdir -p /mount/backups/my_backup/last_backup/
find /mount/backups/my_backup -maxdepth 1 -regex '/mount/backups/my_backup/last_backup/last-backup-.*' -delete

find /mount/backups/my_backup/ -type d -exec chmod 777 {} +
find /mount/backups/my_backup/ -type f -exec chmod 666 {} +
curator --config /conf/curator.yml /conf/action.yml
touch "/mount/backups/my_backup/last_backup/last-backup-$(date -u +"%Y-%m-%d-%H-%M-%Z")"
find /mount/backups/my_backup/ -type d -exec chmod 700 {} +
find /mount/backups/my_backup/ -type f -exec chmod 600 {} +
chown -R "$BACKUP_UID:$BACKUP_UID" /mount/backups/my_backup/

find /usr/share/logstash/output -mtime 3 -delete
