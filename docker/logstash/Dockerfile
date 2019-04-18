FROM docker.elastic.co/logstash/logstash-oss:7.0.0
# Add your logstash plugins setup here
RUN logstash-plugin install logstash-input-udp
RUN logstash-plugin install logstash-input-tcp

COPY logstash/config/logstash.conf /etc/logstash/conf.d/logstash.conf
USER root
