#!/bin/bash

set -ex

# Add curator as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- curator "$@"
fi

# Step down via gosu
if [ "$1" = 'curator' ]; then
	sleep 20
	exec gosu curator bash -c "while true; do curator --config /config/curator.yml /config/action.yml; set -e; sleep $(( 60*60 )); set +e; done"
fi

# As argument is not related to curator,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"
