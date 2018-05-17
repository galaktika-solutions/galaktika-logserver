#!/bin/bash
set -e

if [ "$1" == 'backup' ]; then
  chmod 600 /home/linux_backup/.ssh/id_rsa
  chown -R linux_backup:linux_backup /home/linux_backup/.ssh
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

if [ "$1" == 'start' ]; then
  /usr/local/bin/curator --config /curator_config/curator.yml /curator_config/action.yml
  exit
fi

exec "$@"
