#!/usr/bin/env bash

set -euo pipefail

# Drop root privileges if we are running kafka_connect_exporter
# allow the container to be started with `--user`
if [ "$(basename $1)" = 'collectd-exporter' ] && [ "$(id -u)" = '0' ]; then
  set -- gosu collectd-exporter "$@"
fi

exec "$@"
