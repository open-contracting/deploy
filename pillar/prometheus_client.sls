firewall:
  prometheus_ipv4: 213.138.113.219
  prometheus_ipv6: 2001:41c8:51:7db::219

prometheus:
  node_exporter:
    user: prometheus-client
    service: prometheus-node-exporter
    version: 1.0.1
    config:
      # https://github.com/prometheus/node_exporter/blob/v1.0.1/https/README.md
      config.yaml: salt://prometheus/files/config/config.yaml
      node_exporter.pem: salt://private/keys/node_exporter.pem
