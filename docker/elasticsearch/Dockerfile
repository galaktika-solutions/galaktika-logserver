FROM docker.elastic.co/elasticsearch/elasticsearch-oss:6.2.4

COPY elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
RUN chown root:elasticsearch /etc/elasticsearch/elasticsearch.yml
RUN mkdir -p /mount/backups/my_backup
RUN chmod -R 777 /mount
ENV ES_JAVA_OPTS="-Des.path.conf=/etc/elasticsearch"
