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
