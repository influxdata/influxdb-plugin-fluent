## 1.10.0 [unreleased]

### Dependencies
1. [#40](https://github.com/influxdata/influxdb-plugin-fluent/pull/40): Update dependencies:
    - influxdb-client to 2.7.0

### CI
1. [#39](https://github.com/influxdata/influxdb-plugin-fluent/pull/39): Add Ruby 3.1 into CI

### CI
1. [#32](https://github.com/influxdata/influxdb-plugin-fluent/pull/32): Use new Codecov uploader for reporting code coverage

## 1.9.0 [2021-11-26]

### Features
1. [#30](https://github.com/influxdata/influxdb-plugin-fluent/pull/30): Field value for `time_key` can be formatted date (`2021-11-05 09:15:49.487727165 +0000`, `2021-11-05T10:04:43.617216Z`)
1. [#31](https://github.com/influxdata/influxdb-plugin-fluent/pull/31): Add possibility to use LineProtocol from Fluetd's record.

### Dependencies
1. [#30](https://github.com/influxdata/influxdb-plugin-fluent/pull/30): Update dependencies:
    - influxdb-client to 2.1.0

### CI
1. [#27](https://github.com/influxdata/influxdb-plugin-fluent/pull/27): Switch to next-gen CircleCI's convenience images
1. [#30](https://github.com/influxdata/influxdb-plugin-fluent/pull/30): Add Ruby 3.0 into CI

## 1.8.0 [2021-08-20]

### Features
1. [#26](https://github.com/influxdata/influxdb-plugin-fluent/pull/26): Add placeholder support for bucket & measurement fields

## 1.7.0 [2021-03-05]

### Features
1. [#23](https://github.com/influxdata/influxdb-plugin-fluent/pull/23): Add possibility to specify the certification verification behaviour

### CI
1. [#24](https://github.com/influxdata/influxdb-plugin-fluent/pull/24): Updat stable image to `influxdb:latest` and nightly to `quay.io/influxdb/influxdb:nightly`

## 1.6.0 [2020-10-02]

### API
1. [#15](https://github.com/influxdata/influxdb-plugin-fluent/pull/15): Default port changed from 9999 -> 8086

### Dependencies
1. [#16](https://github.com/influxdata/influxdb-plugin-fluent/pull/16): Upgrade InfluxDB client to 1.8.0

## 1.5.0 [2020-07-17]

1. [#12](https://github.com/influxdata/influxdb-plugin-fluent/pull/12): Rename gem to `fluent-plugin-influxdb-v2`

### Dependencies
1. [#11](https://github.com/influxdata/influxdb-plugin-fluent/pull/11): Upgrade InfluxDB client to 1.6.0

## 1.4.0 [2020-06-19]

### Features
1. [#8](https://github.com/influxdata/influxdb-plugin-fluent/pull/8): Add support for nested fields

### Dependencies
1. [#9](https://github.com/influxdata/influxdb-plugin-fluent/pull/9): Upgrade InfluxDB client to 1.5.0

## 1.3.0 [2020-05-15]

### Dependencies
1. [#6](https://github.com/influxdata/influxdb-plugin-fluent/pull/6): Upgrade InfluxDB client to 1.4.0

## 1.2.0 [2020-03-13]

### Security
1. [#4](https://github.com/influxdata/influxdb-plugin-fluent/pull/4): Upgrade rake to version 12.3.3 - [CVE-2020-8130](https://github.com/advisories/GHSA-jppv-gw3r-w3q8)

### Dependencies
1. [#5](https://github.com/influxdata/influxdb-plugin-fluent/pull/5): Upgrade InfluxDB client

## 1.1.0 [2020-02-14]

### Dependencies
1. [#1](https://github.com/influxdata/influxdb-plugin-fluent/pull/3): Update to stable version of InfluxDB client

## 1.0.0 [2020-01-17]

### Features
1. [#1](https://github.com/influxdata/influxdb-plugin-fluent/pull/1): Initial version of buffered output plugin for InfluxDB 2
 
