FROM ubuntu:xenial-20170214

RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --no-install-recommends \
          rsync \
          openssh-server

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

RUN groupadd -g 1000 myvertis && useradd -u 1000 -m -g 1000 myvertis
RUN mkdir /home/myvertis/.ssh
RUN chown myvertis:myvertis /home/myvertis/.ssh

COPY start-cron /usr/sbin
COPY backup.sh /
COPY docker-entrypoint.sh /
ENTRYPOINT ["./docker-entrypoint.sh"]
