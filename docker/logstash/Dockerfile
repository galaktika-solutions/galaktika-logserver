FROM docker.elastic.co/logstash/logstash-oss:6.2.4

# Add your logstash plugins setup here
RUN logstash-plugin install logstash-input-udp

COPY config/logstash.conf /etc/logstash/conf.d/logstash.conf
USER root
