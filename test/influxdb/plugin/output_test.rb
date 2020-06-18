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

  def test_nested_field
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
      emit_documents(driver, 'location' => 'europe', 'level' => 2,
                             'nest' => { 'key' => 'nested value', 'deep' => { 'deep-key' => 'deep-value' }, 'a' => 25 })
    end
    body = 'h2o_tag level=2i,location="europe",nest.a=25i,nest.deep.deep-key="deep-value",nest.key="nested value" ' \
'1444897215000000000'
    assert_requested(:post, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns',
                     times: 1, body: body)
  end

  def test_kubernetes_structure
    record = {
      'docker' => { 'container_id' => '7ee0723e90d13df5ade6f5d524f23474461fcfeb48a90630d8b02b13c741550b' },
      'kubernetes' => { 'container_name' => 'fluentd',
                        'namespace_name' => 'default',
                        'pod_name' => 'fluentd-49xk2',
                        'container_image' => 'rawkode/fluentd:1',
                        'container_image_id' =>
                            'docker://sha256:90c288b8a09cc6ae98b04078afb10d9c380c0603a47745403461435073460f97',
                        'pod_id' => 'c15ab1cb-0773-4ad7-a58b-f791ab34c62f',
                        'host' => 'minikube',
                        'labels' => {
                          'controller-revision-hash' => '57748799f7',
                          'pod-template-generation' => 2,
                          'app_kubernetes_io/instance' => 'fluentd',
                          'app_kubernetes_io/name' => 'fluentd'
                        },
                        'master_url' => 'https://10.96.0.1:443/api',
                        'namespace_id' => '2b0bc75c-323a-4f04-9eec-02255a8d0044' },
      'log' => '2020-06-17 13:19:42 +0000 [info]: #0 [filter_kube_metadata] stats - namespace_cache_size: 2, '\
'pod_cache_size: 6, pod_cache_watch_updates: 1, namespace_cache_api_updates: 6, '\
'pod_cache_api_updates: 6, id_cache_miss: 6\n',
      'stream' => 'stdout'
    }

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
      emit_documents(driver, record)
    end
    body = 'h2o_tag docker.container_id="7ee0723e90d13df5ade6f5d524f23474461fcfeb48a90630d8b02b13c741550b",'\
'kubernetes.container_image="rawkode/fluentd:1",'\
'kubernetes.container_image_id="docker://sha256:90c288b8a09cc6ae98b04078afb10d9c380c0603a47745403461435073460f97",'\
'kubernetes.container_name="fluentd",kubernetes.host="minikube",'\
'kubernetes.labels.app_kubernetes_io/instance="fluentd",kubernetes.labels.app_kubernetes_io/name="fluentd",'\
'kubernetes.labels.controller-revision-hash="57748799f7",kubernetes.labels.pod-template-generation=2i,'\
'kubernetes.master_url="https://10.96.0.1:443/api",kubernetes.namespace_id="2b0bc75c-323a-4f04-9eec-02255a8d0044",'\
'kubernetes.namespace_name="default",kubernetes.pod_id="c15ab1cb-0773-4ad7-a58b-f791ab34c62f",'\
'kubernetes.pod_name="fluentd-49xk2",log="2020-06-17 13:19:42 +0000 [info]: #0 [filter_kube_metadata] stats - '\
'namespace_cache_size: 2, pod_cache_size: 6, pod_cache_watch_updates: 1, namespace_cache_api_updates: 6, '\
'pod_cache_api_updates: 6, id_cache_miss: 6\\\n",stream="stdout" 1444897215000000000'
    assert_requested(:post, 'https://localhost:9999/api/v2/write?bucket=my-bucket&org=my-org&precision=ns',
                     times: 1, body: body)
  end

  def emit_documents(driver, data = { 'location' => 'europe', 'level' => 2 })
    time = event_time('2015-10-15 8:20:15 UTC')
    driver.feed(time, data)
    time
  end
end
