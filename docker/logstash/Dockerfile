FROM logstash:5.3

# Add your logstash plugins setup here
RUN logstash-plugin update
RUN logstash-plugin install logstash-input-beats
RUN logstash-plugin install logstash-filter-json
RUN logstash-plugin install logstash-filter-grok
RUN logstash-plugin install logstash-output-email
RUN logstash-plugin install logstash-filter-date
RUN logstash-plugin update logstash-filter-date

COPY config/logstash.conf /etc/logstash/conf.d/logstash.conf
