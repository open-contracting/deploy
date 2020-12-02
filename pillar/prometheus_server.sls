prometheus_server:
  fqdn: monitor.prometheus.open-contracting.org
  https: force
  version: 2.20.1
  local_storage_retention: 120d

prometheus_alertmanager:
  fqdn: alertmanager.prometheus.open-contracting.org
  https: force
  version: 0.21.0
