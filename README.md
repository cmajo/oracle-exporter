# Oracle DB Exporter

[![Build Status](https://travis-ci.org/iamseth/oracledb_exporter.svg)](https://travis-ci.org/iamseth/oracledb_exporter)
[![GoDoc](https://godoc.org/github.com/iamseth/oracledb_exporter?status.svg)](http://godoc.org/github.com/iamseth/oracledb_exporter)
[![Report card](https://goreportcard.com/badge/github.com/iamseth/oracledb_exporter)](https://goreportcard.com/badge/github.com/iamseth/oracledb_exporter)

A [Prometheus](https://prometheus.io/) exporter for Oracle modeled after the MySQL exporter. I'm not a DBA or seasoned Go developer so PRs definitely welcomed.

The following metrics are exposed currently.

- oracledb_exporter_last_scrape_duration_seconds
- oracledb_exporter_last_scrape_error
- oracledb_exporter_scrapes_total
- oracledb_up
- oracledb_activity_execute_count
- oracledb_activity_parse_count_total
- oracledb_activity_user_commits
- oracledb_activity_user_rollbacks
- oracledb_sessions_activity
- oracledb_sessions_active (deprecated. Use ``sum(oracledb_sessions_activity{status='ACTIVE'})`` instead.)
- oracledb_sessions_inactive (deprecated. Use ``sum(oracledb_sessions_activity{status='INACTIVE'})`` instead.)
- oracledb_wait_time_application
- oracledb_wait_time_commit
- oracledb_wait_time_concurrency
- oracledb_wait_time_configuration
- oracledb_wait_time_network
- oracledb_wait_time_other
- oracledb_wait_time_scheduler
- oracledb_wait_time_system_io
- oracledb_wait_time_user_io
- oracledb_tablespace_bytes
- oracledb_tablespace_max_bytes
- oracledb_tablespace_bytes_free
- oracledb_resource_current_utilization
- oracledb_resource_limit_value
- oracledb_wait_time_application
- oracledb_wait_time_commit
- oracledb_wait_time_concurrency
- oracledb_wait_time_configuration
- oracledb_wait_time_network
- oracledb_wait_time_other
- oracledb_wait_time_system_io
- oracledb_wait_time_user_io

# Installation

## Docker

You can run via Docker using an existing image. If you don't already have an Oracle server, you can run one locally in a container and then link the exporter to it.

```bash
docker run -d --name oracle -p 1521:1521 wnameless/oracle-xe-11g:16.04
docker run -d --name oracledb_exporter --link=oracle -p 9161:9161 -e DATA_SOURCE_NAME=system/oracle@oracle/xe iamseth/oracledb_exporter

```

## Binary Release

Pre-compiled versions for Linux 64 bit and Mac OSX 64 bit can be found under [releases](https://github.com/iamseth/oracledb_exporter/releases).

In order to run, you'll need the [Oracle Instant Client Basic](http://www.oracle.com/technetwork/database/features/instant-client/index-097480.html) for your operating system. Only the basic version is required for execution.

# Running the Binary

Ensure that the environment variable DATA_SOURCE_NAME is set correctly before starting. For Example

```bash
export DATA_SOURCE_NAME=system/oracle@myhost
/path/to/binary -l log.level error -l web.listen-address 9161
```

## Usage

```bash
Usage of oracledb_exporter:
  -log.format value
       	If set use a syslog logger or JSON logging. Example: logger:syslog?appname=bob&local=7 or logger:stdout?json=true. Defaults to stderr.
  -log.level value
       	Only log messages with the given severity or above. Valid levels: [debug, info, warn, error, fatal].
  -custom.metrics string
        File that may contain various custom metrics in a TOML file.
  -web.listen-address string
       	Address to listen on for web interface and telemetry. (default ":9161")
  -web.telemetry-path string
       	Path under which to expose metrics. (default "/metrics")
```

# Custom metrics

This exporter does not have the metrics you want? You can provide new one using TOML file. To specify this file to the exporter, you can:
- Use ``-custom.metrics`` flag followed by the TOML file
- Export CUSTOM_METRICS variable environment (``export CUSTOM_METRICS=my-custom-metrics.toml``)

This file must contain the following elements:
- One or several metric section (``[[metric]]``)
- For each section a context, a request and a map between a field of your request and a comment.

Here's a simple example:

```
[[metric]]
context = "test"
request = "SELECT 1 as value_1, 2 as value_2 FROM DUAL"
metricsdesc = { value_1 = "Simple example returning always 1.", value_2 = "Same but returning always 2." }
```

This file produce the following entries in the exporter:

```
# HELP oracledb_test_value_1 Simple example returning always.
# TYPE oracledb_test_value_1 gauge
oracledb_test_value_1 1
# HELP oracledb_test_value_2 Same but returning always 2.
# TYPE oracledb_test_value_2 gauge
oracledb_test_value_2 2
```

You can also provide labels using labels field. Here's an example providing two metrics, with and without labels:

```
[[metric]]
context = "context_no_label"
request = "SELECT 1 as value_1, 2 as value_2 FROM DUAL"
metricsdesc = { value_1 = "Simple example returning always 1.", value_2 = "Same but returning always 2." }

[[metric]]
context = "context_with_labels"
labels = [ "label_1", "label_2" ]
request = "SELECT 1 as value_1, 2 as value_2, 'First label' as label_1, 'Second label' as label_2 FROM DUAL"
metricsdesc = { value_1 = "Simple example returning always 1.", value_2 = "Same but returning always 2." }
```

This TOML file while produce the following result:

```
# HELP oracledb_context_no_label_value_1 Simple example returning always 1.
# TYPE oracledb_context_no_label_value_1 gauge
oracledb_context_no_label_value_1 1
# HELP oracledb_context_no_label_value_2 Same but returning always 2.
# TYPE oracledb_context_no_label_value_2 gauge
oracledb_context_no_label_value_2 2
# HELP oracledb_context_with_labels_value_1 Simple example returning always 1.
# TYPE oracledb_context_with_labels_value_1 gauge
oracledb_context_with_labels_value_1{label_1="First label",label_2="Second label"} 1
# HELP oracledb_context_with_labels_value_2 Same but returning always 2.
# TYPE oracledb_context_with_labels_value_2 gauge
oracledb_context_with_labels_value_2{label_1="First label",label_2="Second label"} 2
```

# Integration with Grafana

An example Grafana dashboard is available [here](https://grafana.com/dashboards/3333).
