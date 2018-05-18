#!/bin/bash
set -e

. /utils.sh

if [ "$DEV_MODE" == 'false' ]; then
  check_file "root:root:600" "/.env-files/certificate.pem"
fi

exec "$@"
