# influxdb-plugin-fluent

[![CircleCI](https://circleci.com/gh/influxdata/influxdb-plugin-fluent.svg?style=svg)](https://circleci.com/gh/influxdata/influxdb-plugin-fluent)
[![codecov](https://codecov.io/gh/influxdata/influxdb-plugin-fluent/branch/master/graph/badge.svg)](https://codecov.io/gh/influxdata/influxdb-plugin-fluent)
[![Gem Version](https://badge.fury.io/rb/fluent-plugin-influxdb-v2.svg)](https://badge.fury.io/rb/fluent-plugin-influxdb-v2)
[![License](https://img.shields.io/github/license/influxdata/influxdb-plugin-fluent.svg)](https://github.com/influxdata/influxdb-plugin-fluent/blob/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues-raw/influxdata/influxdb-plugin-fluent.svg)](https://github.com/influxdata/influxdb-plugin-fluent/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr-raw/influxdata/influxdb-plugin-fluent.svg)](https://github.com/influxdata/influxdb-plugin-fluent/pulls)
[![Slack Status](https://img.shields.io/badge/slack-join_chat-white.svg?logo=slack&style=social)](https://www.influxdata.com/slack)

This repository contains the reference Fluentd plugin for the InfluxDB 2.0.

#### Note: This plugin is for use with InfluxDB 2.x. For InfluxDB 1.x instances, please use the [fluent-plugin-influxdb](https://github.com/fangli/fluent-plugin-influxdb) plugin.

## Installation

### Gems

The plugin is bundled as a gem and is hosted on [Rubygems](https://rubygems.org/gems/fluent-plugin-influxdb-v2).  You can install the gem as follows:

```
fluent-gem install fluent-plugin-influxdb-v2 -v 1.5.0
```

## Plugins

### influxdb2

Store Fluentd event to InfluxDB 2 database.

#### Configuration

| Option | Description | Type | Default |
|---|---|---|---|
| url | InfluxDB URL to connect to (ex. https://localhost:8086). | String | https://localhost:8086 |
| token | Access Token used for authenticating/authorizing the InfluxDB request sent by client. | String | |
| use_ssl | Turn on/off SSL for HTTP communication. | bool | true |
| bucket | Specifies the destination bucket for writes. | String | |
| org | Specifies the destination organization for writes. | String | |
| measurement | The name of the measurement. If not specified, Fluentd's tag is used. | String | nil |
| tag_keys | The list of record keys that are stored in InfluxDB as 'tag'. | Array | [] |
| tag_fluentd | Specifies if the Fluentd's event tag is included into InfluxDB tags (ex. 'fluentd=system.logs'). | bool | false |
| field_keys | The list of record keys that are stored in InfluxDB as 'field'. If it's not specified than as fields are used all record keys. | Array | [] |
| field_cast_to_float | Turn on/off auto casting Integer value to Float. Helper to avoid mismatch error: 'series type mismatch: already Integer but got Float'. | bool | false |
| time_precision | The time precision of timestamp. You should specify either second (s), millisecond (ms), microsecond (us), or nanosecond (ns). | String | ns |
| time_key | A name of the record key that used as a 'timestamp' instead of event timestamp. If a record key doesn't exists or hasn't value then is used event timestamp. | String | nil |

##### Minimal configuration

```
<match influxdb2.**>
    @type influxdb2

    # InfluxDB URL to connect to (ex. https://localhost:8086).
    url             https://localhost:8086
    # Access Token used for authenticating/authorizing the InfluxDB request sent by client.
    token           my-token

    # Specifies the destination bucket for writes.
    bucket          my-bucket
    # Specifies the destination organization for writes.
    org             my-org
</match>
```

##### Full configuration

```
<match influxdb2.**>
    @type influxdb2

    # InfluxDB URL to connect to (ex. https://localhost:8086).
    url                     https://localhost:8086
    # Access Token used for authenticating/authorizing the InfluxDB request sent by client.
    token                   my-token
    # Turn on/off SSL for HTTP communication.
    use_ssl                 true

    # Specifies the destination bucket for writes.
    bucket                  my-bucket
    # Specifies the destination organization for writes.
    org                     my-org

    # The name of the measurement. If not specified, Fluentd's tag is used. 
    measurement             h2o
    # The list of record keys that are stored in InfluxDB as 'tag'.
    tag_keys                ["location", "type"]
    # Specifies if the Fluentd's event tag is included into InfluxDB tags (ex. 'fluentd=system.logs).'
    tag_fluentd             true
  
    # The list of record keys that are stored in InfluxDB as 'field'. 
    # If it's not specified than as fields are used all record keys.
    field_keys              ["value"]
    # Turn on/off auto casting Integer value to Float. 
    # Helper to avoid mismatch error: 'series type mismatch: already Integer but got Float'.
    field_cast_to_float     true

    # The time precision of timestamp. You should specify either second (s), millisecond (ms), 
    # microsecond (us), or nanosecond (ns).
    time_precision          s
    # A name of the record key that used as a 'timestamp' instead of event timestamp.
    # If a record key doesn't exists or hasn't value then is used event timestamp.	
    time_key                time
</match>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/influxdata/influxdb-plugin-fluent.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
