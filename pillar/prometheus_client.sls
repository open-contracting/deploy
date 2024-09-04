firewall:
  prometheus_ipv4: 139.162.253.17
  prometheus_ipv6: "2a01:7e00::f03c:93ff:fe13:a12c 2a01:7e00:e000:4e0::/64"

prometheus:
  node_exporter:
    service: prometheus-node-exporter
    user: prometheus-client
    basename: node_exporter
    version: 1.8.2
    config:
      # https://github.com/prometheus/node_exporter/blob/v1.0.1/https/README.md
      config.yaml: salt://prometheus/files/config.yaml
      # Key must match cert_file in config.yaml template.
      node_exporter.pem: prometheus:node_exporter:ssl:pubcert
