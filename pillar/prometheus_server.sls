network:
  host_id: ocp20
  ipv4: 139.162.253.17
  ipv6: "2a01:7e00:e000:04e0::"
  networkd:
    template: linode
    gateway4: 139.162.253.1

prometheus:
  prometheus:
    service: prometheus-server
    user: prometheus-server
    basename: prometheus
    version: 2.45.0
    local_storage_retention: 120d
    config:
      conf-prometheus.yml: salt://prometheus/files/conf-prometheus.yml
      conf-prometheus-rules.yml: salt://prometheus/files/conf-prometheus-rules.yml
      node_exporter.pem: prometheus:node_exporter:ssl:pubcert
  alertmanager:
    service: prometheus-alertmanager
    user: prometheus-alertmanager
    basename: alertmanager
    version: 0.25.0
    config:
      conf-alertmanager.yml: salt://prometheus/files/conf-alertmanager.yml

apache:
  public_access: True
  sites:
    prometheus-server:
      configuration: proxy
      servername: monitor.prometheus.open-contracting.org
      context:
        proxypass: http://localhost:9057/
        authname: Open Contracting Partnership Prometheus Server
    prometheus-alertmanager:
      configuration: proxy
      servername: alertmanager.prometheus.open-contracting.org
      context:
        proxypass: http://localhost:9095/
        authname: Open Contracting Partnership Prometheus Alert Manager
