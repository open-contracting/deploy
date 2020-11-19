kingfisher_process:
  web:
    host: process.kingfisher.open-contracting.org
prometheus_client:
  port: 7231
prometheus_node_exporter:
  smartmon: True
postgres:
  public_access: True
  replica_user:
    username: replica
  replica_ips:
    - 148.251.183.230/32
    - 2a01:4f8:211:de::2/128
  version: 11
  configuration_name: kingfisher-process1
  configuration_file: salt://postgres/configs/kingfisher-process1-postgres.conf
