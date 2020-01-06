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

require 'test_helper'

class InfluxDBOutputTest < Minitest::Test
  def default_config
    %(
      @type influxdb2
      time_precision ns
    )
  end

  def create_driver(conf = default_config)
    Fluent::Test::Driver::Output.new(InfluxDB::Plugin::Fluent::InfluxDBOutput).configure(conf)
  end

  def test_time_precision_parameter
    refute_nil create_driver
    refute_nil create_driver(%(
      @type influxdb2
      time_precision ns
    ))
    refute_nil create_driver(%(
      @type influxdb2
      time_precision us
    ))
    refute_nil create_driver(%(
      @type influxdb2
      time_precision ms
    ))
    refute_nil create_driver(%(
      @type influxdb2
      time_precision s
    ))
    error = assert_raises Fluent::ConfigError do
      create_driver(%(
        @type influxdb2
        time_precision h
    ))
    end

    assert_equal 'The time precision h is not supported. You should use: second (s), millisecond (ms), ' \
                 'microsecond (us), or nanosecond (ns).', error.message
  end
end
