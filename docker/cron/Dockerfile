FROM ubuntu:xenial-20170214

RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --no-install-recommends \
          curl \
          rsync \
          openssh-server \
          python-pip \
          python-dev \
          build-essential \
          python-setuptools


RUN set -ex \
    && apt-get clean && apt-get update \
# install cron
    && apt-get install -y cron \
    && rm -rf /var/lib/apt/lists/* \
# making logging pipe
    && mkfifo --mode 0666 /var/log/cron.log \
# make pam_loginuid.so optional for cron
# see https://github.com/docker/docker/issues/5663#issuecomment-42550548
    && sed --regexp-extended --in-place \
    's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' \
    /etc/pam.d/cron

RUN groupadd -r curator && useradd -r -g curator curator
RUN groupadd -g 1000 myvertis && useradd -u 1000 -m -g 1000 myvertis
RUN pip install --upgrade pip
RUN pip install elasticsearch-curator==5.1.1

COPY curator_config /curator_config
COPY start-cron /usr/sbin
COPY curator-docker-entrypoint.sh /curator-docker-entrypoint.sh
COPY backup-docker-entrypoint.sh /backup-docker-entrypoint.sh
COPY backup.sh /
