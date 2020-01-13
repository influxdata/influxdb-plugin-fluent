FROM fluent/fluentd:edge-debian

# Use root account to use apt
USER root

COPY ./plugins/influxdb-plugin-fluent-1.0.0.gem /fluentd/plugins

RUN fluent-gem install influxdb-client --pre
RUN fluent-gem install /fluentd/plugins/influxdb-plugin-fluent-1.0.0.gem

# below RUN includes plugin as examples elasticsearch is not required
# you may customize including plugins as you wish
#RUN buildDeps="sudo make gcc g++ libc-dev" \
# && apt-get update \
# && apt-get install -y --no-install-recommends $buildDeps \
# && sudo gem install /etc/fluent/plugin/influxdb-plugin-fluent.gem

#ENV PATH /home/fluent/.gem/ruby/2.2.0/bin:$PATH
#RUN gem install /fluentd/plugins/fluent-plugin-influxdb2.gem

#RUN export GEM_HOME=/usr/local/bundle/gems
#RUN buildDeps="sudo make gcc g++ libc-dev" \
# && apt-get update \
# && apt-get install -y --no-install-recommends $buildDeps \
# && sudo gem install --verbose /fluentd/plugins/fluent-plugin-influxdb2.gem \
# && sudo gem sources --clear-all \
# && SUDO_FORCE_REMOVE=yes \
#    apt-get purge -y --auto-remove \
#                  -o APT::AutoRemove::RecommendsImportant=false \
#                  $buildDeps \
# && rm -rf /var/lib/apt/lists/* \
# && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

COPY ./fluent.conf /fluentd/etc/
COPY entrypoint.sh /bin/

USER fluent