#!/bin/bash
set -e

chmod 600 /home/myvertis/.ssh/id_rsa
chown -R myvertis:myvertis /home/myvertis/.ssh

exec "$@"
