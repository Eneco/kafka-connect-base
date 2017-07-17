#!/usr/bin/env bash

function push_config {
    # wait until local connect's REST API comes up
    until $CLI_CMD ps >>/dev/null
    do
        echo "Waiting for connect's rest API at $KAFKA_CONNECT_REST"
        sleep 1
    done

    echo "Validating the connector config..."
    if ! $CLI_CMD validate $CONNECTOR_CONNECTOR_CLASS < $APP_PROPERTIES_FILE; then
      echo "failed validation."
      exit 1
    fi

    echo "Pushing connector config..."
    $CLI_CMD run $CONNECTOR_NAME < $APP_PROPERTIES_FILE
    echo "done."
}

APP_PROPERTIES_FILE=/etc/config/connector.properties
CLI_JAR=/opt/datamountaineer/jars/kafka-connect-cli-all.jar

# cli expects this env var
export KAFKA_CONNECT_REST="http://127.0.0.1:$CONNECT_REST_PORT"
CLI_CMD="java -jar $CLI_JAR"

# Create
echo "Creating connector properties file"
mkdir /etc/config
dub template "/etc/confluent/docker/connector.properties.template" "$APP_PROPERTIES_FILE"

if [ $CONNECT_MODE = 'STANDALONE' ]; then
  export APP_PROPERTIES_FILE
  exec /etc/confluent/docker/standalone/run
else
  # Push from another process
  push_config &
  exec /etc/confluent/docker/run
fi

# EOF
