FROM ubuntu:xenial-20180417

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
RUN groupadd -g 1000 linux_backup && useradd -u 1000 -m -g 1000 linux_backup
RUN pip install --upgrade pip
RUN pip install elasticsearch-curator==5.4.0

COPY curator/curator_config /curator_config
COPY curator/start-cron /usr/sbin
COPY curator/entrypoint.sh /entrypoint.sh
COPY curator/backup.sh /
COPY utils.sh /

ENTRYPOINT ["./entrypoint.sh"]
