#!/bin/bash
set -e

chown -R myvertis:myvertis /home/myvertis/.ssh

exec "$@"
