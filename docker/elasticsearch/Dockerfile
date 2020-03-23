FROM docker.elastic.co/elasticsearch/elasticsearch-oss:7.6.1

COPY elasticsearch/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
RUN chown root:elasticsearch /usr/share/elasticsearch/config/elasticsearch.yml
RUN mkdir -p /mount/backups/my_backup
RUN chown -R elasticsearch:elasticsearch /mount/backups/my_backup
RUN chmod -R 777 /mount
ENV ES_JAVA_OPTS="-Des.path.conf=/etc/elasticsearch"
