FROM ubuntu:xenial-20180417

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install stunnel4 -y
COPY stunnel/stunnel.conf /etc/stunnel/stunnel.conf
COPY stunnel/entrypoint.sh /entrypoint.sh
COPY utils.sh /

ENTRYPOINT ["./entrypoint.sh"]
CMD ["stunnel"]
