FROM fluent/fluentd:edge-debian

USER root

COPY ./influxdb-plugin-fluent.gem /fluentd/plugins

RUN fluent-gem install /fluentd/plugins/influxdb-plugin-fluent.gem

COPY ./fluent.conf /fluentd/etc/
COPY entrypoint.sh /bin/

USER fluent