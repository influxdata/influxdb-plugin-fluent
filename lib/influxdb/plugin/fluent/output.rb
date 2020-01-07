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

require 'fluent/plugin/output'
require 'influxdb/client'

# rubocop:disable Style/ClassAndModuleChildren
module InfluxDB::Plugin::Fluent
  # A buffered output plugin for Fluentd and InfluxDB 2
  class InfluxDBOutput < Fluent::Plugin::Output
    Fluent::Plugin.register_output('influxdb2', self)

    helpers :inject, :compat_parameters

    DEFAULT_BUFFER_TYPE = 'memory'.freeze

    config_param :url, :string, default: 'https://localhost:9999'
    desc 'InfluxDB URL to connect to (ex. https://localhost:9999).'

    config_param :token, :string
    desc 'Access Token used for authenticating/authorizing the InfluxDB request sent by client.'

    config_param :bucket, :string
    desc 'Specifies the destination bucket for writes.'

    config_param :org, :string
    desc 'Specifies the destination organization for writes.'

    config_param :measurement, :string, default: nil
    desc 'The name of the measurement. If not specified, Fluentd\'s tag is used.'

    config_param :time_precision, :string, default: 'ns'
    desc 'The time precision of timestamp. You should specify either second (s), ' \
        'millisecond (ms), microsecond (us), or nanosecond (ns).'

    config_section :buffer do
      config_set_default :@type, DEFAULT_BUFFER_TYPE
      config_set_default :chunk_keys, ['tag']
    end

    def configure(conf)
      compat_parameters_convert(conf, :inject)
      super
      case @time_precision
      when 'ns' then
        @precision_formatter = ->(ns_time) { ns_time }
      when 'us' then
        @precision_formatter = ->(ns_time) { (ns_time / 1e3).round }
      when 'ms' then
        @precision_formatter = ->(ns_time) { (ns_time / 1e6).round }
      when 's' then
        @precision_formatter = ->(ns_time) { (ns_time / 1e9).round }
      else
        raise Fluent::ConfigError, "The time precision #{@time_precision} is not supported. You should use: " \
                                   'second (s), millisecond (ms), microsecond (us), or nanosecond (ns).'
      end
      @precision = InfluxDB::WritePrecision.new.get_from_value(@time_precision)
      raise Fluent::ConfigError, 'The InfluxDB URL should be defined.' if @url.empty?
    end

    def start
      super
      @client = InfluxDB::Client.new(@url, @token, bucket: @bucket, org: @org, precision: @precision)
      @write_api = @client.create_write_api
    end

    def shutdown
      super
      @client.close!
    end

    def multi_workers_ready?
      true
    end

    def write(chunk)
      points = []
      measurement = @measurement || chunk.metadata.tag
      chunk.msgpack_each do |time, record|
        nano_seconds = time.sec * 1e9
        nano_seconds += time.nsec
        point = InfluxDB::Point
                .new(name: measurement)
                .time(nano_seconds, @precision)
        record.each_pair do |k, v|
          point.add_field(k, v)
        end
        points << point
      end
      @write_api.write(data: points)
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
