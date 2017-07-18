FROM confluentinc/cp-kafka-connect:3.2.0

#
# CLI and template for pushing connector properties
#
ENV CLI_VERSION=1.0
RUN mkdir -p /opt/datamountaineer/jars && \
    cd /opt/datamountaineer/jars && wget https://github.com/datamountaineer/kafka-connect-tools/releases/download/v${CLI_VERSION}/kafka-connect-cli-${CLI_VERSION}-all.jar \
    -O kafka-connect-cli$-{CLI_VERSION}-all.jar && \
    ln -s kafka-connect-cli$-{CLI_VERSION}-all.jar kafka-connect-cli-all.jar
COPY templates/connector.properties.template /etc/confluent/docker/connector.properties.template

#
# Launch script
#
COPY entrypoint.sh /etc/confluent/entrypoint.sh
RUN chmod +x /etc/confluent/entrypoint.sh
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

#
# Liveliness probe
#
RUN apt-get update && apt-get install jq
COPY liveliness.sh /etc/confluent/liveliness.sh

#
# jmx exporter
#
COPY config.yaml /etc/jmx_exporter/config.yaml
RUN mkdir -p /opt/jmx_exporter && \
    wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.7/jmx_prometheus_javaagent-0.7.jar -O \
    /opt/jmx_exporter/jmx_prometheus_javaagent-0.7.jar
ENV KAFKA_JMX_OPTS="-javaagent:/opt/jmx_exporter/jmx_prometheus_javaagent-0.7.jar=9102:/etc/jmx_exporter/config.yaml"
EXPOSE 9102

#
# alternate distributed launch - overwrite classpath
#
RUN mkdir -p /usr/local/share/java
COPY distributed/launch /etc/confluent/docker/launch

#
# alternate standalone launch - overwrite classpath, launch standalone mode
#
COPY standalone /etc/confluent/docker/standalone
RUN chmod +x /etc/confluent/docker/standalone/*

CMD ["dumb-init", "/etc/confluent/entrypoint.sh"]
