FROM logstash:5.5

# Add your logstash plugins setup here
RUN logstash-plugin install logstash-input-beats
RUN logstash-plugin install logstash-filter-json
RUN logstash-plugin install logstash-filter-grok
RUN logstash-plugin install logstash-input-udp
RUN logstash-plugin install logstash-input-file
RUN logstash-plugin install logstash-output-file
RUN logstash-plugin install logstash-output-stdout
RUN logstash-plugin install logstash-filter-mutate
RUN logstash-plugin install logstash-filter-syslog_pri


COPY patterns /opt/patterns
COPY config/logstash.conf /etc/logstash/conf.d/logstash.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
