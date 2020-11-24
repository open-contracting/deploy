prometheus_client:
  port: 7231
prometheus_node_exporter:
  smartmon: True
vm:
  nr_hugepages: 8325
postgres:
  public_access: True
  version: 11
  configuration_name: kingfisher-replica1
  configuration_file: salt://postgres/configs/kingfisher-replica1-postgres.conf
