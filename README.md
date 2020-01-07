# influxdb-plugin-fluent

[![CircleCI](https://circleci.com/gh/bonitoo-io/influxdb-plugin-fluent.svg?style=svg)](https://circleci.com/gh/bonitoo-io/influxdb-plugin-fluent)
[![codecov](https://codecov.io/gh/bonitoo-io/influxdb-plugin-fluent/branch/master/graph/badge.svg)](https://codecov.io/gh/bonitoo-io/influxdb-plugin-fluent)
[![Gem Version](https://badge.fury.io/rb/influxdb-plugin-fluent.svg)](https://badge.fury.io/rb/influxdb-plugin-fluent)
[![License](https://img.shields.io/github/license/bonitoo-io/influxdb-plugin-fluent.svg)](https://github.com/bonitoo-io/influxdb-plugin-fluent/blob/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues-raw/bonitoo-io/influxdb-plugin-fluent.svg)](https://github.com/bonitoo-io/influxdb-plugin-fluent/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr-raw/bonitoo-io/influxdb-plugin-fluent.svg)](https://github.com/bonitoo-io/influxdb-plugin-fluent/pulls)

This repository contains the reference Fluentd plugin for the InfluxDB 2.0.

#### Note: This plugin is for use with InfluxDB 2.x. For InfluxDB 1.x instances, please use the [fluent-plugin-influxdb](https://github.com/fangli/fluent-plugin-influxdb) plugin.

## Installation

### Gems

The plugin is bundled as a gem and is hosted on [Rubygems](https://rubygems.org/gems/influxdb-plugin-fluent).  You can install the gem as follows:

```
fluent-gem install influxdb-plugin-fluent
```

## Plugins

### influxdb2

Store Fluentd event to InfluxDB 2 database.

#### Configuration

| Option | Description | Type | Default |
|---|---|---|---|
| url | InfluxDB URL to connect to (ex. http://localhost:9999). | String | http://localhost:9999 |
| token | Access Token used for authenticating/authorizing the InfluxDB request sent by client. | String | |
| bucket | Specifies the destination bucket for writes. | String | |
| org | Specifies the destination organization for writes. | String | |
| time_precision | The time precision of timestamp. You should specify either second (s), millisecond (ms), microsecond (us), or nanosecond (ns). | String | ns |

##### Example

```
<match influxdb2.**>
    @type influxdb2

    # InfluxDB URL to connect to (ex. http://localhost:9999).
    url             http://localhost:9999
    # Access Token used for authenticating/authorizing the InfluxDB request sent by client.
    token           my-token

    # Specifies the destination bucket for writes.
    bucket          my-bucket
    # Specifies the destination organization for writes.
    org             my-org
  
    # The time precision of timestamp. You should specify either second (s), millisecond (ms), 
    # microsecond (us), or nanosecond (ns).
    time_precision  s
</match>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bonitoo-io/influxdb-plugin-fluent.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
