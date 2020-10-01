#!/usr/bin/env bash
#
# The MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

set -e

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

docker kill influxdb_v2 || true
docker rm influxdb_v2 || true

docker kill fluentd_influx || true
docker rm fluentd_influx || true

docker kill web || true
docker rm web || true

docker kill ab || true
docker rm ab || true

docker network rm influx_network || true
docker network create -d bridge influx_network --subnet 192.168.0.0/24 --gateway 192.168.0.1

#
# Start InfluxDB 2
#
docker run \
       --detach \
       --env INFLUXD_HTTP_BIND_ADDRESS=:8086 \
       --name influxdb_v2 \
       --network influx_network \
       --publish 8086:8086 \
       quay.io/influxdb/influxdb:2.0.0-rc

#
# Post onBoarding request to InfluxDB 2
#
"${SCRIPT_PATH}"/../bin/influxdb-onboarding.sh

#
# Build actual version of output plugin
#
cd "${SCRIPT_PATH}"/../
docker run --rm -v "${SCRIPT_PATH}/../":/usr/src/app -w /usr/src/app ruby:2.6 gem build fluent-plugin-influxdb-v2.gemspec \
  -o ./examples/fluentd/fluent-plugin-influxdb-v2.gem

#
# Build fluentd Docker image with output plugin
#
docker build -t fluentd_influx examples/fluentd

#
# Start fluentd with docker image
#
docker run \
       --detach \
       --name fluentd_influx \
       --network influx_network \
       --publish 24224:24224 \
       --publish 24220:24220 \
       fluentd_influx

echo "Wait to start fluentd"
wget -S --tries=20 --retry-connrefused --waitretry=5 --output-document=/dev/null http://localhost:24220/api/plugins.json

#
# Start WebApp
#
docker run \
       --detach \
       --name web \
       --network influx_network \
       --volume "${SCRIPT_PATH}"/web/httpd.conf:/usr/local/apache2/conf/httpd.conf \
       --publish 8080:80 \
       --log-driver fluentd \
       --log-opt tag=httpd.access \
       httpd

echo "Wait to start WebApp"
wget -S --spider --tries=20 --retry-connrefused --waitretry=5 http://localhost:8080

#
# Run Apache Benchmark to simulate load
#
docker run \
        --detach \
        --name ab \
        --network influx_network \
        --volume "${SCRIPT_PATH}"/ab/urls.txt:/tmp/urls.txt \
        --volume "${SCRIPT_PATH}"/ab/load.sh:/tmp/load.sh \
        russmckendrick/ab bash /tmp/load.sh

docker logs -f fluentd_influx

#curl -i -X POST -H "Content-Type: application/json" -H "Authorization: Token my-token" "http://localhost:8086/orgs/3c7a552ae6b01ebd/dashboards/import" -d @influxdb/web_app_access_dashboard.json
