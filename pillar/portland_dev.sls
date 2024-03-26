network:
  host_id: ocp26
  ipv4: 20.106.239.92

ntp:
  - 0.us.pool.ntp.org
  - 1.us.pool.ntp.org
  - 2.us.pool.ntp.org
  - 3.us.pool.ntp.org

apache:
  public_access: True
  sites:
    portland:
      configuration: default
      servername: portland-dev.open-contracting.org

docker:
  user: deployer

postgres:
  version: 16
  # Docker containers don't use localhost to connect to the host's PostgreSQL service. Public access is controlled using Azure's firewall.
  public_access: True
  configuration: False
