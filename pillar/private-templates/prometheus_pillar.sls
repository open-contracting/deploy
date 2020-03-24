prometheus:
  client_password: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  # use "openssl passwd -apr1" to generate this. Use the same password as above.
  client_password_as_nginx_file: "prom:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_fqdn:
  client_port: 80
  server_password: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  alertmanager_password: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  server_fqdn: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  server_local_storage_retention: 30d
  alertmanager_fqdn: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  server_https: force
  alertmanager_https: force
  server_prometheus_version: 2.12.0
  server_alertmanager_version: 0.18.0
  node_exporter_version: 0.18.1
