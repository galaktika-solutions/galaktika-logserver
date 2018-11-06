FROM ubuntu:bionic-20181018


RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --no-install-recommends \
          curl \
          locales \
          rsync \
          openssh-server \
          python-pip \
          python-dev \
          build-essential \
          python-setuptools \
          stunnel4

# python
RUN apt-get install -y python3.6 python3-venv
RUN python3.6 -m venv /python
ENV PATH /python/bin:$PATH
ENV PYTHONPATH /src/python_packages/:/src/frontend/
ENV PYTHONUNBUFFERED 1

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

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
RUN pip install --no-cache-dir \
  elasticsearch-curator==5.5.4 \
  periodtask==0.7.0

COPY conf /conf
COPY conf/stunnel.conf /etc/stunnel/stunnel.conf
COPY docker/main/entrypoint.sh /entrypoint.sh
COPY services/ /services
COPY docker/utils.sh /

ENTRYPOINT ["./entrypoint.sh"]
