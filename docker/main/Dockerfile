FROM ubuntu:focal-20210416

ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update && apt-get install -y locales curl stunnel4 build-essential

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
# python
RUN apt-get install -y software-properties-common python3.9 python3-venv python-is-python3 python3-pip
ENV PATH /python/bin:$PATH
ENV PYTHONUNBUFFERED 1

RUN python -m pip install -U pip
RUN pip3 install --no-cache-dir vertis-periodtask==0.8.0
RUN pip3 install --no-cache-dir elasticsearch-curator==5.8.4
RUN pip3 install --no-cache-dir gdockutils==0.5.16

COPY conf /conf
COPY conf/stunnel.conf /etc/stunnel/stunnel.conf
COPY docker/main/entrypoint.sh /entrypoint.sh
COPY services/ /services
COPY docker/utils.sh /

ENTRYPOINT ["./entrypoint.sh"]
