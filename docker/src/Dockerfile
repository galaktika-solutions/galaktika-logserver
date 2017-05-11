
FROM ubuntu:xenial-20170214

RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --no-install-recommends \
          rsync

RUN mkdir /src

CMD ["true"]
