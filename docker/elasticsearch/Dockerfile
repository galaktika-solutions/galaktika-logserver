FROM elasticsearch:5.6.9

COPY elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
RUN chown root:elasticsearch /etc/elasticsearch/elasticsearch.yml
RUN mkdir -p /mount/backups/my_backup
RUN chmod -R 777 /mount
ENV ES_JAVA_OPTS="-Des.path.conf=/etc/elasticsearch"
