#!/bin/bash
set -e

. /utils.sh

site="elasticsearch:9200/_snapshot/my_backup";
function response() {
  chmod 777 /mount/backups/my_backup
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

if [ "$1" == 'manual_backup' ]; then
  response
  bash /services/curator/curator.sh
  exit
fi


if [ "$1" == 'restore' ]; then
  response
  curator --config /conf/curator.yml /conf/restore_action.yml
  exit
fi

if [ "$1" == 'stunnel' ]; then
  if [ "$DEV_MODE" == 'False' ]; then
    check_file "root:root:600" "/.env-files/certificate.pem"
    stunnel
  fi
fi


if [ "$1" == 'curator' ]; then
  if [ "$CURATOR_SERVICE" == 'True' ]; then
  response
  python /services/curator/start.py
  fi
  exit 0
fi

exec "$@"
