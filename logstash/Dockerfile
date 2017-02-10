FROM logstash:5

# Add your logstash plugins setup here
RUN logstash-plugin update
RUN logstash-plugin install logstash-input-beats
RUN logstash-plugin install logstash-filter-json
RUN logstash-plugin install logstash-filter-mutate
