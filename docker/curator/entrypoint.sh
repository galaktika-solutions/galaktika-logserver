#!/bin/bash
set -e

. /utils.sh

chmod 777 /mount/backups/my_backup

if [ "$DEV_MODE" == 'false' ]; then
  check_file "root:root:600" "/.env-files/id_rsa"
  check_file "root:root:600" "/.env-files/certificate.key"
  check_file "root:root:600" "/.env-files/certificate.pem"
fi

site="elasticsearch:9200/_snapshot/my_backup";
function response() {

  response=$(curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X PUT $site -d \
  '{
    "type": "fs",
    "settings": {
      "location": "/mount/backups/my_backup",
      "compress": true
    }
  }' 2>/dev/null | head -n1)
  if [ "$response" == '' ]; then
    echo 'Elasticsearch connection failed try again 10 sec'
    sleep 10
    response
  else
    echo $response
    echo 'Elasticsearch connected'
  fi

}

if [ "$1" == 'backup' ]; then
  mkdir -p /home/linux_backup/.ssh
  proc_file -c linux_backup:linux_backup:400 /.env-files/id_rsa /home/linux_backup/.ssh/id_rsa
  proc_file -c linux_backup:linux_backup:400 /.env-files/id_rsa.pub /home/linux_backup/.ssh/id_rsa.pub
  proc_file -c linux_backup:linux_backup:400 /.env-files/known_hosts /home/linux_backup/.ssh/known_hosts
  if [ "$2" == 'scp' ]; then
    exec su linux_backup -c ./backup.sh
    exit 0
  fi
  if [ "$SSH_BACKUP_SERVICE" == 'true' ]; then
    start-cron --user linux_backup "${BACKUP_CRON}"
  fi
  exit 0
fi


if [ "$1" == 'manual_backup' ]; then
  response
  /usr/local/bin/curator --config /curator_config/curator.yml /curator_config/action.yml
  exit
fi


if [ "$1" == 'restore' ]; then
  response
  /usr/local/bin/curator --config /curator_config/curator.yml /curator_config/restore_action.yml
  exit
fi

if [ "$1" == 'curator' ]; then
  if [ "$CURATOR_SERVICE" == 'true' ]; then
  response
  start-cron --user curator "${CURATOR_CRON}"
  exit
  fi
  exit 0
fi

exec "$@"
