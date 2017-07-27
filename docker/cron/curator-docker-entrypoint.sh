#!/bin/bash
set -e

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
}


if [ "$1" == 'bash' ]; then
  exec "$@"
fi

if [ "$1" == 'restore' ]; then
  response
  if [ "$response" != '' ]; then
    /usr/local/bin/curator --config /curator_config/curator.yml /curator_config/restore_action.yml
    exit
  else
    echo 'elasticsearch DOWN please start the elasticsearch'
    exit
  fi
fi

if [ "$1" != 'bash' ] || [ "$1" != 'restore' ]; then
  response
  echo 'Wait elasticsearch'
  echo 'elasticsearch status:'
  if [ "$response" != '' ]; then
    echo 'elasticsearch UP'
  else
    echo 'elasticsearch DOWN wait 30 sec and try again'
    sleep 30
    response
    if [ "$response" != '' ]; then
      echo 'elasticsearch UP'
    else
      echo 'elasticsearch DOWN'
      exit
    fi
  fi
  exec "$@"
fi
