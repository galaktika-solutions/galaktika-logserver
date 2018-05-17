#!/bin/bash
set -e

set -e

. /utils.sh

if [ "$DEV_MODE" == 'false' ]; then
  check_file "root:root:600" "/.env"
fi


if [ "$1" == 'backup' ]; then
  mkdir -p /home/linux_backup/.ssh
  proc_file -c linux_backup:linux_backup:400 /.env-files/id_rsa /home/linux_backup/.ssh/id_rsa
  proc_file -c linux_backup:linux_backup:400 /.env-files/id_rsa.pub /home/linux_backup/.ssh/id_rsa.pub
  proc_file -c linux_backup:linux_backup:400 /.env-files/known_hosts /home/linux_backup/.ssh/known_hosts
  start-cron --user linux_backup "${BACKUP_CRON}"
fi

  ## Try not to use UPPER CASE variables to avoid conflicts
  ## with the default environmental variable names.
chmod 777 /mount/backups/my_backup
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

response


if [ "$1" == 'bash' ]; then
  exec "$@"
fi

if [ "$1" == 'restore' ]; then
  /usr/local/bin/curator --config /curator_config/curator.yml /curator_config/restore_action.yml
  exit
fi

if [ "$1" == 'curator' ]; then
  /usr/local/bin/curator --config /curator_config/curator.yml /curator_config/action.yml
  exit
fi

exec "$@"
