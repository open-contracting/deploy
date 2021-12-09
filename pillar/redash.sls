host_id: ocp14

network:
  netplan: True
  ipv4:
    primary_ip: 139.162.199.85
    primary_ip_subnet_mask: "/24"
    gateway_ip: 139.162.199.1
    dns_servers: [ 178.79.182.5, 176.58.107.5, 176.58.116.5, 176.58.121.5, 151.236.220.5, 212.71.252.5, 212.71.253.5, 109.74.192.20, 109.74.193.20, 109.74.194.20 ]
  ipv6:
    primary_ip: 2a01:7e00:e000:02cc::14
    slaac_ip: 2a01:7e00::f03c:92ff:fea5:0e5f/128
    gateway_ip: fe80::1
    dns_servers: [ 2a01:7e00::9, 2a01:7e00::3, 2a01:7e00::c, 2a01:7e00::5, 2a01:7e00::6, 2a01:7e00::8, 2a01:7e00::b, 2a01:7e00::4, 2a01:7e00::7, 2a01:7e00::2 ]
  search_domain: open-contracting.org

apache:
  public_access: True
  sites:
    redash:
      configuration: proxy
      servername: redash.open-contracting.org
      context:
        proxypass: http://localhost:9090/

postgres:
  version: 13
  # Redash connections to Postgres are not sent over the localhost connection.
  # Postgres access is locked down further in the Linode firewall.
  public_access: true
  configuration: redash
  storage: ssd
  type: oltp
  nr_hugepages: 128

docker:
  user: deployer
  docker_compose:
    version: 1.29.2
docker_apps:
  redash:
    target: redash
    env:
      PYTHONUNBUFFERED: 0
      REDASH_LOG_LEVEL: INFO
      REDASH_REDIS_URL: redis://redis:6379/0
      REDASH_FEATURE_SHOW_PERMISSIONS_CONTROL: true
      REDASH_MAIL_SERVER: email-smtp.us-east-1.amazonaws.com
      REDASH_MAIL_PORT: 587
      REDASH_MAIL_USE_TLS: true
      REDASH_MAIL_DEFAULT_SENDER: noreply@noreply.open-contracting.org
      REDASH_HOST: https://redash.open-contracting.org
