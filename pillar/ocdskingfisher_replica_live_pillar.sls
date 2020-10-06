postgres:
  public_access: True
  version: 11
  custom_configuration: salt://postgres/configs/kingfisher-replica1-postgres.conf

prometheus:
  client_port: 7231
  client_node_exporter_textfile_collector_smartmon: True
