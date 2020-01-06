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
