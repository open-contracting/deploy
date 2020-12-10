prometheus:
  prometheus:
    user: prometheus-server
    service: prometheus-server
    version: 2.20.1
    local_storage_retention: 120d
    config:
      conf-prometheus.yml: salt://prometheus/files/conf-prometheus.yml
      conf-prometheus-rules.yml: salt://prometheus/files/conf-prometheus-rules.yml
      node_exporter.pem: salt://private/keys/node_exporter.pem
  alertmanager:
    user: prometheus-alertmanager
    service: prometheus-alertmanager
    version: 0.21.0
    config:
      conf-alertmanager.yml: salt://prometheus/files/conf-alertmanager.yml

apache:
  public_access: true
  sites:
    prometheus-server:
      configuration: prometheus-server
      servername: monitor.prometheus.open-contracting.org
      https: force
    prometheus-alertmanager:
      configuration: prometheus-alertmanager
      servername: alertmanager.prometheus.open-contracting.org
      https: force
