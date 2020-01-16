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
  include Fluent::Test::Helpers
  class MockInfluxDBOutput < InfluxDBOutput
    attr_reader :client

    def write(chunk)
      super
    end
  end

  def setup
    Fluent::Test.setup
    WebMock.disable_net_connect!
  end

  def default_config
    %(
      @type influxdb2
      token my-token
      bucket my-bucket
      org my-org
      time_precision ns
    )
  end

  def create_driver(conf = default_config)
    Fluent::Test::Driver::Output.new(MockInfluxDBOutput).configure(conf)
  end

  def test_configuration
    driver = create_driver
    driver.run(default_tag: 'input.influxdb2') do
    end
    assert_equal driver.instance.multi_workers_ready?, true
  end

  def test_time_precision_parameter
    refute_nil create_driver
    conf = %(
      @type influxdb2
      token my-token
      bucket my-bucket
      org my-org
      time_precision %s
    )
    refute_nil create_driver(format(conf, 'ns'))
    refute_nil create_driver(format(conf, 'us'))
    refute_nil create_driver(format(conf, 'ms'))
    refute_nil create_driver(format(conf, 's'))
    error = assert_raises Fluent::ConfigError do
      create_driver(format(conf, 'h'))
    end

    assert_equal 'The time precision h is not supported. You should use: second (s), millisecond (ms), ' \
                 'microsecond (us), or nanosecond (ns).', error.message
  end

  def test_url_parameter
    error = assert_raises Fluent::ConfigError do
      create_driver(%(
        @type influxdb2
        url
        token my-token
        bucket my-bucket
        org my-org
    ))
    end

    assert_equal 'The InfluxDB URL should be defined.', error.message
  end

  def test_token_parameter
    error = assert_raises Fluent::ConfigError do
      create_driver(%(
        @type influxdb2
        bucket my-bucket
        org my-org
    ))
    end

    assert_equal '\'token\' parameter is required', error.message
  end

  def test_use_ssl_parameter
    error = assert_raises Fluent::ConfigError do
      create_driver(%(
        @type influxdb2
        bucket my-bucket
        org my-org
        token my-token
        use_ssl not_bool
    ))
    end

    assert_equal '\'use_ssl\' parameter is required but nil is specified', error.message
  end

  def test_bucket_parameter
    error = assert_raises Fluent::ConfigError do
      create_driver(%(
      @type influxdb2
      token my-token
      org my-org
      time_precision ns
    ))
    end

    assert_equal '\'bucket\' parameter is required', error.message
  end

  def test_org_parameter
    error = assert_raises Fluent::ConfigError do
      create_driver(%(
      @type influxdb2
      token my-token
      bucket my-bucket
      time_precision ns
    ))
    end

    assert_equal '\'org\' parameter is required', error.message
  end

  def test_has_client
    driver = create_driver
    driver.run(default_tag: 'input.influxdb2') do
    end
    refute_nil driver.instance.client
  end

  def test_measurement_as_parameter
    stub_request(:any, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns')
      .to_return(status: 204)
    driver = create_driver(%(
      @type influxdb2
      token my-token
      bucket my-bucket
      org my-org
      measurement h2o
      time_precision ns
    ))
    driver.run(default_tag: 'test') do
      emit_documents(driver)
    end
    assert_requested(:post, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns',
                     times: 1, body: 'h2o level=2i,location="europe" 1444897215000000000')
  end

  def test_measurement_as_tag
    stub_request(:any, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns')
      .to_return(status: 204)
    driver = create_driver(%(
      @type influxdb2
      token my-token
      bucket my-bucket
      org my-org
      time_precision ns
    ))
    driver.run(default_tag: 'h2o_tag') do
      emit_documents(driver)
    end
    assert_requested(:post, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns',
                     times: 1, body: 'h2o_tag level=2i,location="europe" 1444897215000000000')
  end

  def test_tag_keys
    stub_request(:any, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns')
      .to_return(status: 204)
    driver = create_driver(%(
      @type influxdb2
      token my-token
      bucket my-bucket
      org my-org
      tag_keys ["location"]
    ))
    driver.run(default_tag: 'h2o_tag') do
      emit_documents(driver)
    end
    assert_requested(:post, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns',
                     times: 1, body: 'h2o_tag,location=europe level=2i 1444897215000000000')
  end

  def test_tag_fluentd
    stub_request(:any, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns')
      .to_return(status: 204)
    driver = create_driver(%(
      @type influxdb2
      token my-token
      bucket my-bucket
      org my-org
      measurement h2o
      tag_keys ["location"]
      tag_fluentd true
    ))
    driver.run(default_tag: 'system.logs') do
      emit_documents(driver)
    end
    assert_requested(:post, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns',
                     times: 1, body: 'h2o,fluentd=system.logs,location=europe level=2i 1444897215000000000')
  end

  def test_field_keys
    stub_request(:any, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns')
      .to_return(status: 204)
    driver = create_driver(%(
      @type influxdb2
      token my-token
      bucket my-bucket
      org my-org
      tag_keys ["location"]
      field_keys ["level"]
    ))
    driver.run(default_tag: 'h2o_tag') do
      emit_documents(driver, 'location' => 'europe', 'level' => 2, 'version' => 'v.10')
    end
    assert_requested(:post, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns',
                     times: 1, body: 'h2o_tag,location=europe level=2i 1444897215000000000')
  end

  def test_time_precision_ns
    stub_request(:any, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns')
      .to_return(status: 204)
    driver = create_driver(%(
      @type influxdb2
      token my-token
      bucket my-bucket
      org my-org
      tag_keys ["version"]
      time_precision ns
    ))
    driver.run(default_tag: 'h2o_tag') do
      emit_documents(driver, 'location' => 'europe', 'level' => 2, 'version' => 'v.10')
    end
    assert_requested(:post, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns',
                     times: 1, body: 'h2o_tag,version=v.10 level=2i,location="europe" 1444897215000000000')
  end

  def test_time_integer
    stub_request(:any, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns')
      .to_return(status: 204)
    driver = create_driver(%(
      @type influxdb2
      token my-token
      bucket my-bucket
      org my-org
    ))
    driver.run(default_tag: 'h2o_tag') do
      driver.feed(123_465_789, 'location' => 'europe', 'level' => 2, 'version' => 'v.10')
    end
    assert_requested(:post, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns',
                     times: 1, body: 'h2o_tag level=2i,location="europe",version="v.10" 123465789')
  end

  def test_time_precision_us
    stub_request(:any, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=us')
      .to_return(status: 204)
    driver = create_driver(%(
      @type influxdb2
      token my-token
      bucket my-bucket
      org my-org
      tag_keys ["version"]
      time_precision us
    ))
    driver.run(default_tag: 'h2o_tag') do
      emit_documents(driver, 'location' => 'europe', 'level' => 2, 'version' => 'v.10')
    end
    assert_requested(:post, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=us',
                     times: 1, body: 'h2o_tag,version=v.10 level=2i,location="europe" 1444897215000000')
  end

  def test_time_precision_ms
    stub_request(:any, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ms')
      .to_return(status: 204)
    driver = create_driver(%(
      @type influxdb2
      token my-token
      bucket my-bucket
      org my-org
      tag_keys ["version"]
      time_precision ms
    ))
    driver.run(default_tag: 'h2o_tag') do
      emit_documents(driver, 'location' => 'europe', 'level' => 2, 'version' => 'v.10')
    end
    assert_requested(:post, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ms',
                     times: 1, body: 'h2o_tag,version=v.10 level=2i,location="europe" 1444897215000')
  end

  def test_time_precision_s
    stub_request(:any, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=s')
      .to_return(status: 204)
    driver = create_driver(%(
      @type influxdb2
      token my-token
      bucket my-bucket
      org my-org
      tag_keys ["version"]
      time_precision s
    ))
    driver.run(default_tag: 'h2o_tag') do
      emit_documents(driver, 'location' => 'europe', 'level' => 2, 'version' => 'v.10')
    end
    assert_requested(:post, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=s',
                     times: 1, body: 'h2o_tag,version=v.10 level=2i,location="europe" 1444897215')
  end

  def test_time_key
    stub_request(:any, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns')
      .to_return(status: 204)
    driver = create_driver(%(
      @type influxdb2
      token my-token
      bucket my-bucket
      org my-org
      tag_keys ["version"]
      time_key time
    ))
    driver.run(default_tag: 'h2o_tag') do
      emit_documents(driver, 'location' => 'europe', 'level' => 2, 'version' => 'v.10',
                             'time' => 1_544_897_215_000_000_000)
    end
    assert_requested(:post, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns',
                     times: 1, body: 'h2o_tag,version=v.10 level=2i,location="europe" 1544897215000000000')
  end

  def test_field_cast_to_float
    stub_request(:any, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns')
      .to_return(status: 204)
    driver = create_driver(%(
      @type influxdb2
      token my-token
      bucket my-bucket
      org my-org
      field_cast_to_float true
    ))
    driver.run(default_tag: 'h2o_tag') do
      emit_documents(driver)
    end
    assert_requested(:post, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns',
                     times: 1, body: 'h2o_tag level=2.0,location="europe" 1444897215000000000')
  end

  def emit_documents(driver, data = { 'location' => 'europe', 'level' => 2 })
    time = event_time('2015-10-15 8:20:15 UTC')
    driver.feed(time, data)
    time
  end
end
