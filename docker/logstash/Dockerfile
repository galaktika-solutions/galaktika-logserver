FROM logstash:5.5

# Add your logstash plugins setup here
RUN logstash-plugin install logstash-input-beats
RUN logstash-plugin install logstash-filter-json
RUN logstash-plugin install logstash-filter-grok

COPY config/logstash.conf /etc/logstash/conf.d/logstash.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
