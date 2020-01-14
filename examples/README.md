# InfluxDB 2 + Fluentd

InfluxDB 2 and Fluentd together are able to collect large amount of logs and transform it to useful metrics. 
InfluxDB 2 provide a solution for realtime analysis and alerting over collected metrics.

## Introduction

[Fluentd](https://www.fluentd.org/architecture) is an open source data collector, which lets you unify the data collection and consumption for a better use and understanding of data.

[InfluxDB](https://www.influxdata.com) open source time series database, purpose-built by InfluxData for monitoring metrics and events, provides real-time visibility into stacks, sensors, and systems. 

## Architecture

The following demo show how to analyze logs from dockerized environment.

### Step 1: 
### Step 2: 
### Step 3:

Open [InfluxDB](http://localhost:9999) and import dashboard [web_app_access.json](examples/influxdb/web_app_access.json) by following steps:

> username: my-user
>
> password: my-password

1. Click the **Dashboards** icon in the navigation bar.
1. Click the **Create Dashboard** menu in the upper right and select **Import Dashboard**.
1. Select **Upload File** to drag-and-drop or select a **web_app_access.json**.
1. Click **Import JSON** as Dashboard.

The imported dashboard should look like this:

<img src="dashboard.png" height="400px">

 
## Conclusion

Analyze Apache access log is just one way how to use power of InfluxDB and Fluentd. 
There are other things you could do with InfluxDB and Fluentd and next step could be a [Monitoring and alerting](https://v2.docs.influxdata.com/v2.0/monitor-alert/#manage-your-monitoring-and-alerting-pipeline). 

### Links

- https://docs.fluentd.org/installation/install-by-dmg
- https://www.digitalocean.com/community/tutorials/how-to-centralize-your-docker-logs-with-fluentd-and-elasticsearch-on-ubuntu-16-04
- https://stackoverflow.com/questions/58563760/docker-compose-pulls-an-two-images-an-app-and-fluentd-but-no-logs-are-sent-to-s
- https://docs.fluentd.org/v/0.12/container-deployment/docker-compose