# InfluxDB 2 + Fluentd

InfluxDB 2 and Fluentd together are able to collect large amount of logs and transform it to useful metrics. 
InfluxDB 2 provide a solution for realtime analysis and alerting over collected metrics.

## Introduction

[Fluentd](https://www.fluentd.org/architecture) is an open source data collector, which lets you unify the data collection and consumption for a better use and understanding of data.

[InfluxDB](https://www.influxdata.com) open source time series database, purpose-built by InfluxData for monitoring metrics and events, provides real-time visibility into stacks, sensors, and systems. 

## Architecture

The following demo show how to analyze logs from dockerized environment.

<img src="dashboard.png" height="250px">

### Links

- https://docs.fluentd.org/installation/install-by-dmg
- https://www.digitalocean.com/community/tutorials/how-to-centralize-your-docker-logs-with-fluentd-and-elasticsearch-on-ubuntu-16-04
- https://stackoverflow.com/questions/58563760/docker-compose-pulls-an-two-images-an-app-and-fluentd-but-no-logs-are-sent-to-s
- https://docs.fluentd.org/v/0.12/container-deployment/docker-compose