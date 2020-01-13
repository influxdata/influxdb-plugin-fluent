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

# Build actual version of output plugin
# gem build influxdb-plugin-fluent.gemspec -o examples/fluentd/influxdb-plugin-fluent.gem

# Start docker compose
cd "${SCRIPT_PATH}"
docker-compose up -d --build

#curl -i -X POST http://localhost:9999/api/v2/setup -H 'accept: application/json' \
#    -d '{
#            "username": "my-user",
#            "password": "my-password",
#            "org": "my-org",
#            "bucket": "my-bucket",
#            "token": "my-token"
#        }'


docker logs -f fluentd