# `kafka-connect-base`

Base image for containerising Kafka Connectors. This is based on the Confluent Kafka Connect docker for Confluent 3.2.0.

## Features

- `entrypoint.sh` runs Kafka Connect in distributed mode and posts a connector configuration once it is running.
- `liveliness.sh` checks the status of the tasks running on this container.
- [`jmx_exporter-0.7`](https://github.com/prometheus/jmx_exporter) runs as a java agent and exports Kafka consumer and producer metrics on port 9102.
- `kafka-connect-cli-1.0.jar` from datamountaineer for interacting with the connect cluster at launch.

## Modification to `confluentinc/cp-kafka-connect:3.2.0`

The launch scripts has been edited to change the class path. This allows third party
jars to be put in `/usr/local/share/java/` and will be picked up at runtime.

## Tests

To test the `liveliness.sh` probe, install `jq` and run `test.sh`
