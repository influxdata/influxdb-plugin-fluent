FROM fluent/fluentd:edge-debian

USER root

COPY ./fluent-plugin-influxdb-v2.gem /fluentd/plugins

RUN fluent-gem install /fluentd/plugins/fluent-plugin-influxdb-v2.gem

COPY ./fluent.conf /fluentd/etc/
COPY entrypoint.sh /bin/

USER fluent