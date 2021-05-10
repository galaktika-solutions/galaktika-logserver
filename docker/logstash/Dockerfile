FROM docker.elastic.co/logstash/logstash-oss:7.10.2
# Add your logstash plugins setup here
RUN logstash-plugin install logstash-input-udp
RUN logstash-plugin install logstash-input-tcp
RUN logstash-plugin install logstash-output-file

COPY logstash/config/logstash.conf /etc/logstash/conf.d/logstash.conf
COPY logstash/patterns /usr/share/logstash/pipeline/patterns
USER root
RUN chown -R logstash:logstash /usr/share/logstash/pipeline/patterns
