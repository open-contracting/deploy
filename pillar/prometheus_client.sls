firewall:
  prometheus_ipv4: 178.79.132.58
  prometheus_ipv6: "2a01:7e00::2000:a4ff:fe05:0492 2a01:7e00:e000:4e3::/64"

prometheus:
  node_exporter:
    service: prometheus-node-exporter
    user: prometheus-client
    basename: node_exporter
    version: 1.12.1
    config:
      # https://github.com/prometheus/node_exporter/blob/v1.0.1/https/README.md
      config.yaml: salt://prometheus/files/config.yaml
      # Key must match cert_file in config.yaml template.
      node_exporter.pem: prometheus:node_exporter:ssl:pubcert
